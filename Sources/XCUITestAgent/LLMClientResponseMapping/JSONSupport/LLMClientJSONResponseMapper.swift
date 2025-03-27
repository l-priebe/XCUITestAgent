import Foundation
import CoreGraphics

public struct LLMClientJSONResponseMapper: LLMClientResponseMapper {
    public enum LLMClientJSONResponseMapperError: Error {
        case decodingError(reason: String)
    }

    private let decoder: JSONDecoder
    private let frameMapper: LLMClientResponseFrameMapper

    public init(decoder: JSONDecoder = JSONDecoder(), frameMapper: LLMClientResponseFrameMapper) {
        self.decoder = decoder
        self.frameMapper = frameMapper
    }

    public func map(response: String) throws -> ActionSequence {
        guard let responseData = response.data(using: .utf8) else {
            throw LLMClientJSONResponseMapperError.decodingError(
                reason: "Unable to convert response string to data"
            )
        }

        let codedResponse = try decoder.decode(
            LLMClientActionSequenceReponse.self,
            from: responseData
        )

        let actions = try mapActions(codedResponse.actions)

        return ActionSequence(
            description: codedResponse.description,
            actions: actions,
            delayUntilNextSequence: codedResponse.delayUntilNextSequence
        )
    }
}

extension LLMClientJSONResponseMapper {
    fileprivate func mapActions(_ actions: [LLMClientReponseAction]) throws -> [Action] {
        return try actions.map { action in
            switch action.actionType {
            case .tap:
                guard
                    let _elementFrame = action.elementFrame, !_elementFrame.isEmpty
                else {
                    throw LLMClientJSONResponseMapperError.decodingError(
                        reason: "Invalid tap action (no element frame provided)"
                    )
                }
                let elementFrame = try frameMapper.map(_elementFrame)
                return .tap(elementFrame: elementFrame)

            case .enterText:
                guard let text = action.text, !text.isEmpty else {
                    throw LLMClientJSONResponseMapperError.decodingError(
                        reason: "Invalid text action (text: nil or empty)"
                    )
                }
                guard
                    let _elementFrame = action.elementFrame, !_elementFrame.isEmpty
                else {
                    throw LLMClientJSONResponseMapperError.decodingError(
                        reason: "Invalid enter text action (no element frame provided)"
                    )
                }
                let elementFrame = try frameMapper.map(_elementFrame)
                return .enterText(elementFrame: elementFrame, text: text)

            case .swipe:
                guard
                    let _direction = action.swipeDirection,
                    let direction = SwipeDirection(rawValue: _direction.rawValue)
                else {
                    throw LLMClientJSONResponseMapperError.decodingError(
                        reason: "Invalid swipe action (swipe direction: \(action.swipeDirection?.rawValue ?? ""))"
                    )
                }
                guard
                    let _elementFrame = action.elementFrame, !_elementFrame.isEmpty
                else {
                    throw LLMClientJSONResponseMapperError.decodingError(
                        reason: "Invalid swipe action (no element frame provided)"
                    )
                }
                let elementFrame = try frameMapper.map(_elementFrame)
                return .swipe(
                    elementFrame: elementFrame,
                    direction: direction
                )

            case .idle:
                return .idle

            case .success:
                return .success

            case .failure:
                return .failure
            }
        }
    }
}
