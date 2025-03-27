import Foundation

public protocol LLMClient {
    func prompt(_ prompt: LLMClientPrompt) async throws -> String
}
