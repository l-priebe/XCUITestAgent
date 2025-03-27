import Foundation

struct LLMClientReponseAction: Codable {
    let actionType: LLMClientResponseActionType
    let elementFrame: String?
    let swipeDirection: LLMClientResponseSwipeDirection?
    let text: String?
}
