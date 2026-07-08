/// Sendable wrapper for the parsed preset catalog crossing the invoke boundary.
nonisolated public struct ToolchainCatalog: Sendable, Codable, Equatable {
    public var presets: [ParsedPreset]
}
