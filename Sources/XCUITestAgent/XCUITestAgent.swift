import Foundation
import XCTest

open class XCUITestAgent: UITestAgent {
    public init(
        app: XCUIApplication,
        client: LLMClient
    ) {
        super.init(
            client: client,
            responseMapper: LLMClientJSONResponseMapper(
                frameMapper: XCUITestFrameMapper()
            ),
            promptProvider: XCUITestAgentPromptProvider(app: app),
            actionPerformer: XCUITestAgentActionPerformer(app: app)
        )
    }
}
