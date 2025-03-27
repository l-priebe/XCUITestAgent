import Foundation

public protocol UITestAgentPromptProvider {
    func makePrompt(_ testPrompt: String, actionHistory: [ActionSequence]) throws -> LLMClientPrompt
}
