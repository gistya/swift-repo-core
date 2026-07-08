import Foundation

nonisolated public struct TrackerModuleTrack: Hashable, Sendable {
    public let url: URL
    public let fileName: String
    public let title: String
    public let format: String
    
    public nonisolated func nowPlaying(moduleTitle: String?) -> SoundtrackNowPlaying {
        let parts = Self.displayParts(from: title)
        return SoundtrackNowPlaying(
            title: moduleTitle?.nilIfEmpty ?? parts.title,
            artist: parts.artist,
            detail: format
        )
    }

    public nonisolated static func displayParts(from rawTitle: String) -> (title: String, artist: String) {
        let separators = ["_-_", " - ", " – "]
        for separator in separators {
            if let range = rawTitle.range(of: separator) {
                let artist = cleanedDisplayText(String(rawTitle[..<range.lowerBound]))
                let title = cleanedDisplayText(String(rawTitle[range.upperBound...]))
                return (
                    title: title.nilIfEmpty ?? cleanedDisplayText(rawTitle),
                    artist: artist.nilIfEmpty ?? "TRACKER MODULE"
                )
            }
        }
        return (
            title: cleanedDisplayText(rawTitle),
            artist: "TRACKER MODULE"
        )
    }

    public nonisolated static func cleanedDisplayText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
            .uppercased()
    }
}
