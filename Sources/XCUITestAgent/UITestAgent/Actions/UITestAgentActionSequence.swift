import Foundation

public struct ActionSequence {
    public let description: String
    public let actions: [Action]
    public let delayUntilNextSequence: TimeInterval?

    public init(
        description: String,
        actions: [Action],
        delayUntilNextSequence: TimeInterval? = nil
    ) {
        self.description = description
        self.actions = actions
        self.delayUntilNextSequence = delayUntilNextSequence
    }
}
