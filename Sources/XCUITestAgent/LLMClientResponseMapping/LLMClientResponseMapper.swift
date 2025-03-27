import Foundation

public protocol LLMClientResponseMapper {
    func map(response: String) throws -> ActionSequence
}
