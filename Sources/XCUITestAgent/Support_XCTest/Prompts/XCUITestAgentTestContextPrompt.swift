import Foundation

struct XCUITestAgentTestContextPrompt {
    func make(previousActionDescriptions: [String]) -> String? {
        if !previousActionDescriptions.isEmpty {
            let additionalContext = """
                Additional context:
                The test is already in progress and the following steps have been attempted prior to now. Try not to repeat any of the previous actions unless specifically needed: \(previousActionDescriptions.joined(separator: ", ")).
            """
            return additionalContext
        } else {
            return """
                Additional context:
                The test has just started.
            """
        }
    }
}
