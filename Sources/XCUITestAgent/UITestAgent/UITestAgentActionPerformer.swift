import Foundation

public protocol UITestAgentActionPerformer {
    func perform(_ actionSequence: ActionSequence)
}
