nonisolated public enum MusicSettings {
    public static let current: SoundPalette = SoundPalette(
        sampleRate: 44_100,
        masterVolume: 0.45,
        loopDuration: 8,
        startupCueDuration: 2.2,
        failureCueDuration: 1.7,
        successCueDuration: 1.0,
        buildingBPM: 142,
        testingBPM: 168,
        measuringBPM: 104,
        deployingBPM: 128,
        streamBufferFrames: 65_536,
        streamPrerollFrames: 16_384,
        streamRenderChunkFrames: 8_192,
        maxRenderedTrackDuration: 600,
        trackEndTailDuration: 2,
        trackerModuleDirectory: "TrackerModules",
        trackerModuleExtensions: ["mod", "xm", "it"],
    )
}
