import SwiftXState

nonisolated public struct ToolchainContext: Sendable, Equatable {
    public var presetFilePath: String = ""
    public var catalog: [ParsedPreset] = []
    public var draft: ToolchainRecipeDraft = ToolchainRecipeDraft()
    public var lastError: String?
    
    public init() {}
    
    public init(presetFilePath: String, catalog: [ParsedPreset], draft: ToolchainRecipeDraft, lastError: String? = nil) {
        self.presetFilePath = presetFilePath
        self.catalog = catalog
        self.draft = draft
        self.lastError = lastError
    }

    /// Composed presets (runnable) vs mixin building blocks — for the two catalog panes.
    public var composedPresets: [ParsedPreset] { catalog.filter { !$0.isMixin }.sorted { $0.name < $1.name } }
    public var mixinPresets: [ParsedPreset] { catalog.filter { $0.isMixin }.sorted { $0.name < $1.name } }
}
