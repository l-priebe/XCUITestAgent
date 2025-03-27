import Foundation

public enum Action {
    case tap(elementFrame: CGRect)
    case enterText(elementFrame: CGRect, text: String)
    case swipe(elementFrame: CGRect, direction: SwipeDirection)
    case idle
    case success
    case failure
}
