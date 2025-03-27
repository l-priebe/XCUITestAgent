import Foundation

public protocol LLMClientResponseFrameMapper {
    func map(_ frameString: String) throws -> CGRect
}
