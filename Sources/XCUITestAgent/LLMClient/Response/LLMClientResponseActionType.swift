import Foundation

enum LLMClientResponseActionType: String, Codable {
    case tap
    case enterText
    case swipe
    case idle
    case success
    case failure
}
