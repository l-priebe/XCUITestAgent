import Foundation
import XCTest

public struct XCUITestAgentPromptProvider: UITestAgentPromptProvider {
    private let app: XCUIApplication
    private let encoder = JSONEncoder()
    
    public init(app: XCUIApplication) {
        self.app = app
    }

    public func makePrompt(_ testPrompt: String, actionHistory: [ActionSequence]) throws -> LLMClientPrompt {
        return LLMClientPrompt(
            systemPrompt: XCUITestAgentSystemPrompt().make(
                responseFormat: .json,
                responseExamples: responseExamples(),
                additionalResponseDescription: XCUITestAgentAdditionalResponseDescriptionPrompt().make()
            ),
            testPrompt: testPrompt,
            testContext: XCUITestAgentTestContextPrompt().make(
                previousActionDescriptions: actionHistory.map {
                    $0.description
                }
            ),
            screenshotData: makeScreenshotData(app: app),
            debugViewHierarchy: debugHierarchy(of: app)
        )
    }
}

// MARK: - Response examples

extension XCUITestAgentPromptProvider {
    fileprivate func responseExamples() -> [XCUITestAgentSystemPrompt.ResponseExample] {
        return [
            XCUITestAgentSystemPrompt.ResponseExample(
                description: "Example response for tapping the screen",
                response: responseExample(LLMClientActionSequenceReponse(
                    description: "Tap '111' on the keyboard.",
                    actions: [
                        .init(
                            actionType: .tap,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: nil
                        ),
                        .init(
                            actionType: .tap,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: nil
                        ),
                        .init(
                            actionType: .tap,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: nil
                        )
                    ],
                    delayUntilNextSequence: 1
                ))
            ),
            XCUITestAgentSystemPrompt.ResponseExample(
                description: "Example response for entering text into a textfield",
                response: responseExample(LLMClientActionSequenceReponse(
                    description: "Enter text '7258' into the reg nr. field.",
                    actions: [
                        .init(
                            actionType: .enterText,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: "7258"
                        )
                    ],
                    delayUntilNextSequence: 1
                ))
            ),
            XCUITestAgentSystemPrompt.ResponseExample(
                description: "Example response for entering text into two different textfields on the same screen",
                response: responseExample(LLMClientActionSequenceReponse(
                    description: "Enter text '7258' into the reg nr. field. and '123412333' into the account number field.",
                    actions: [
                        .init(
                            actionType: .enterText,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: "7258"
                        ),
                        .init(
                            actionType: .enterText,
                            elementFrame: "{{250.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: nil,
                            text: "123412333"
                        )
                    ],
                    delayUntilNextSequence: 1
                ))
            ),
            XCUITestAgentSystemPrompt.ResponseExample(
                description: "Example response for swiping an element from left to right",
                response: responseExample(LLMClientActionSequenceReponse(
                    description: "Swipe the confirm to swipe control.",
                    actions: [
                        .init(
                            actionType: .swipe,
                            elementFrame: "{{100.0, 200.0}, {120.0, 60.0}}",
                            swipeDirection: .right,
                            text: nil
                        )
                    ],
                    delayUntilNextSequence: 1
                ))
            ),
            XCUITestAgentSystemPrompt.ResponseExample(
                description: "Example response for succeeding the test",
                response: responseExample(LLMClientActionSequenceReponse(
                    description: "Succeed the test because the screen contains a photo of a dog as required.",
                    actions: [
                        .init(
                            actionType: .success,
                            elementFrame: nil,
                            swipeDirection: nil,
                            text: nil
                        )
                    ],
                    delayUntilNextSequence: nil
                ))
            )
        ]
    }

    fileprivate func responseExample(_ encodable: Encodable) -> String {
        return (try? encoder.encode(encodable))?.base64EncodedString() ?? ""
    }
}

// MARK: - Screenshot processing

extension XCUITestAgentPromptProvider {
    fileprivate func makeScreenshotData(app: XCUIApplication) -> Data? {
        return app.screenshot().image
            .scaled(toMaxHeight: 768)?
            .jpegData(compressionQuality: 0.80)
    }
}

extension UIImage {
    fileprivate func scaled(toMaxHeight maxHeight: CGFloat) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        
        // If height is already within limits, return the original image
        if self.size.height <= maxHeight {
            return self
        }
        
        // Calculate new width while maintaining aspect ratio
        let newHeight = maxHeight
        let newWidth = newHeight * aspectRatio
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Render the new image
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

// MARK: - Debug view hierarchy

extension XCUITestAgentPromptProvider {
    fileprivate func debugHierarchy(of app: XCUIApplication) -> String {
        var output = app.debugDescription
        output = removePattern(", 0x[0-9a-fA-F]+", from: output)
        output = removePattern(", pid: \\d+", from: output)
        output = removePattern(#"identifier: '.*?'\s?"#, from: output)
        return output
    }

    fileprivate func removePattern(_ pattern: String, from input: String) -> String {
        do {
            let regex = try NSRegularExpression(
                pattern: pattern,
                options: []
            )
            let modifiedString = regex.stringByReplacingMatches(
                in: input,
                options: [],
                range: NSRange(input.startIndex..., in: input),
                withTemplate: ""
            )
            return modifiedString
        } catch {
            return input
        }
    }
}
