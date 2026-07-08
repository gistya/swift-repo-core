nonisolated public struct SoundPalette: Codable, Equatable, Hashable, Sendable {
    public var sampleRate: Double
    public var masterVolume: Float
    public var loopDuration: Double
    public var startupCueDuration: Double
    public var failureCueDuration: Double
    public var successCueDuration: Double
    public var buildingBPM: Double
    public var testingBPM: Double
    public var measuringBPM: Double
    public var deployingBPM: Double
    public var streamBufferFrames: Int
    public var streamPrerollFrames: Int
    public var streamRenderChunkFrames: Int
    public var maxRenderedTrackDuration: Double
    public var trackEndTailDuration: Double
    public var trackerModuleDirectory: String
    public var trackerModuleExtensions: [String]
}
