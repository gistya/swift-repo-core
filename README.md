# SwiftRepoCore

SwiftRepoCore is the business logic backend for SwiftBuild, a desktop application that checks out and builds the Swift toolchain from source. It is a plain Swift package with no user interface code in it at all: no SwiftUI, no AppKit, no SwiftData, no platform windowing. What lives here is the model layer, the services that do the real work, and the state machines that describe how the application behaves. A front-end of any kind, on any platform, can be built on top of it.

The macOS version of SwiftBuild, the SwiftRepoGUI project, is the first front-end built on this package. The whole point of separating the logic into its own package is that a Linux front-end or a Windows front-end can be written against the same backend, sharing every bit of behavior and differing only in presentation. This document explains what is in the package, how a front-end uses it, and how someone could go about writing a Linux or Windows port. Help with those ports is welcome, and the section near the end is written as an open invitation to anyone who wants to take it on.

## What SwiftBuild does

SwiftBuild is a graphical control panel for building the Swift compiler and its surrounding toolchain. You point it at a local checkout of the Swift project (a directory that contains `swift/utils/build-script` and `swift/utils/update-checkout`), choose the repositories and build options you want, and it assembles the correct `build-script` command line, launches it, streams progress and log output back to you, and records the result. On top of that it offers saved build profiles, composable toolchain recipes and presets, a theming system, and a small chiptune soundtrack feature. All of the behavior behind those features, apart from the drawing of pixels, is implemented in this package.

## What is in this package

The single library product is `SwiftRepoCore`. Its sources are organized into three groups.

Models. Plain value types that describe the domain. This includes the full set of build options and their catalog and preset parsing (`BuildOptions`, `BuildOptionCatalog`, `BuildPresetParser`), records of past build operations, project and repository descriptions, toolchain recipes and presets, the theme and palette types, and the data types for the soundtrack feature. These are ordinary Codable, Sendable Swift structs and enums with no platform ties.

Services. The code that actually interacts with the world. `ProjectService` validates a checkout and discovers its repositories using git. `BuildCommandBuilder` turns a set of options into the argument list for `build-script`. `BuildJobPlanner`, `BuildProcessRunner`, `ProcessPipeReader`, `ProgressParser`, `BuildOutputTail`, and `BuildLogWriter` launch the build process, read its output, translate that output into progress updates, and persist logs. A small concurrency layer (`AsyncProcess`, `AsyncEventBroadcaster`, `AsyncOneShotSignal`, `ProcessExitSignal`) runs child processes and delivers their exit and output without blocking cooperative threads. `AppPaths` resolves the application's support, logs, and exports directories.

State machines. The behavior of the application, expressed as statecharts on top of the SwiftXState library. There is a machine for top-level navigation, one for the project (idle, loading, loaded, failed), one for build settings, one for build operations, one for toolchain composition, and one for appearance. Each machine is a description of states, events, guards, and actions. A front-end drives these machines and renders whatever state they are in.

## How a front-end uses it

The division of labor is simple. This package owns all logic and state. The front-end owns the window, the widgets, and the wiring between them.

A front-end holds a `MachineStore` for each machine it needs. It reads the machine's current state and context to decide what to show, and it sends events to the machine in response to user actions. When a machine's action needs to do real work, such as validating a project or running a build, it calls into the services described above. Because the machines and services are plain Swift with no UI dependency, the same store can back a SwiftUI view on macOS, a SwiftOpenUI view on Linux, or a native control on Windows, without any change to the logic.

The macOS front-end adds the parts that must be platform specific: the SwiftUI views, SwiftData persistence for saved records, and the audio engine that plays the soundtrack. None of that lives here, which is exactly what makes the package portable.

## Portability by design

A few deliberate choices keep this package close to portable already.

It depends only on the Swift standard library, Foundation, and two small pure-Swift packages: SwiftXState for the state machines and CompositionalInit for initialization helpers. There is no dependency on AppKit, UIKit, SwiftUI, or SwiftData.

Process launching, file access, and git invocation go through Foundation, which is available on Linux and Windows as well as Apple platforms.

The handful of places that genuinely need an Apple-only API are isolated behind `#if canImport(Darwin)` with a portable path already written for the other side. Those places are:

| File | Apple platforms | Elsewhere |
| --- | --- | --- |
| `ProjectAccessBookmark` | Security-scoped bookmarks that keep access to the chosen project folder across launches | A no-op stub, since there is no sandbox to satisfy |
| `LogFileEventSource` | A Dispatch file-system event source that watches the log file | A modification-time polling fallback |
| `CoreLocalized` | Wraps `String(localized:)` for localized strings | Returns the string unchanged |

The package already compiles on Linux. Windows has not been tried yet and is the larger of the two undertakings.

## Writing a Linux or Windows port

This is the future direction the package was built for, and anyone is invited to take part. The goal is a version of SwiftBuild that runs on Linux, on Windows, or both, reusing this backend unchanged as far as possible. Here is a sensible way to approach it.

Start by building the library on your platform. On Linux this already works with a recent Swift toolchain; `swift build` produces the `SwiftRepoCore` library. On Windows this is the first thing to try, and any compile failures you find are the concrete list of work to do. Fixing them should mean adding portable branches next to existing code, not rewriting logic.

Choose a user interface toolkit for your platform. The macOS front-end uses SwiftUI. A Linux front-end could use SwiftOpenUI, GTK, or Qt through a Swift binding. A Windows front-end could use SwiftUI through the community Windows support, WinUI through Swift and WinRT, or a cross-platform toolkit. The choice does not affect this package.

Bind your interface to the state machines. For each screen, hold the relevant `MachineStore`, render from its state and context, and send events on user actions. Because the machines are already written, this step is mostly presentation. The macOS front-end is a working reference for which machines exist and how they connect.

Supply the platform-specific service behavior. Walk the three gated files listed above and decide what each should do on your platform. On Linux the existing non-Darwin branches are a reasonable starting point. On Windows you may want to replace the polling log watcher with a native file-change notification, and the bookmark stub can stay a no-op. Check the process-launching code as well: `AsyncProcess` currently resolves git at a fixed Unix path, so a port should locate git on `PATH` and use the correct executable name, and `BuildProcessRunner` seeds `PATH` with Unix directories that a Windows port would replace with the right locations.

Confirm the toolchain build path. SwiftBuild drives the Swift project's `build-script`, which is a Python program, so the target platform needs Python available and invoked correctly. Verify that a real build runs end to end on your platform before considering the port complete.

Contribute the portable pieces back. The ideal outcome is that platform differences live inside this package as small gated branches, so that one shared backend serves every front-end. If you are working on a port and want guidance on where a seam belongs, open an issue or a pull request and start the conversation.

## Building and testing

```
swift build
swift test
```

The package targets a recent Swift toolchain and uses the Swift 6 language mode. It builds on macOS and on Linux today. Building on Windows is an open task and a good first contribution.

## Status and contributions

The macOS front-end is the working application today. Linux support at the library level is in place, a Linux front-end is in progress, and Windows is untried. If any of that interests you, contributions are welcome, whether that is a full front-end, a single portable service branch, or a fix that gets the library compiling somewhere new.
