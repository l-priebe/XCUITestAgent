import Foundation

struct LLMClientActionSequenceReponse: Codable {
    let description: String
    let actions: [LLMClientReponseAction]
    let delayUntilNextSequence: TimeInterval?
}
