import Foundation

public extension LLMClient {
    func prompt(_ prompt: LLMClientPrompt, mapper: LLMClientResponseMapper) async throws -> ActionSequence {
        let response: String = try await self.prompt(prompt)
        return try mapper.map(response: response)
    }
}
