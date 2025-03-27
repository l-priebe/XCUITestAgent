import Foundation

public struct LLMClientPrompt {
    /// System prompt describing intended agent behaviour and llm response format.
    public let systemPrompt: String

    /// Test prompt describing the test that is to be performed by the agent.
    public let testPrompt: String

    /// Any context in addition to the test prompt, e.g. any actions taken prioer to the current prompt.
    public let testContext: String?

    /// Screenshot of the app prior to prompting.
    public let screenshotData: Data?

    /// Debug description of view hierarchy including frames of views.
    public let debugViewHierarchy: String
}
