import Foundation

public struct XCUITestFrameMapper: LLMClientResponseFrameMapper {
    public enum XCUITestFrameMapperError: Error {
        case decodingError(reason: String)
    }

    public init() {}
    
    public func map(_ frameString: String) throws -> CGRect {
        // Regular expression pattern to match the frame format "{{x, y}, {width, height}}"
        let pattern = "\\{\\{([0-9.-]+), ([0-9.-]+)\\}, \\{([0-9.-]+), ([0-9.-]+)\\}\\}"

        // Create the regular expression
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        // Search for the pattern in the input string
        if let match = regex?.firstMatch(in: frameString, options: [], range: NSRange(location: 0, length: frameString.utf16.count)) {

            // Extract x, y, width, and height using captured groups
            let xRange = match.range(at: 1)
            let yRange = match.range(at: 2)
            let widthRange = match.range(at: 3)
            let heightRange = match.range(at: 4)

            // Get the values as strings
            let xString = (frameString as NSString).substring(with: xRange)
            let yString = (frameString as NSString).substring(with: yRange)
            let widthString = (frameString as NSString).substring(with: widthRange)
            let heightString = (frameString as NSString).substring(with: heightRange)

            // Convert the strings to integers
            if let x = Double(xString), let y = Double(yString), let width = Double(widthString), let height = Double(heightString) {
                return CGRect(
                    x: x,
                    y: y,
                    width: width,
                    height: height
                )
            }
        }

        throw XCUITestFrameMapperError.decodingError(
            reason: "Invalid element frame: \(frameString)"
        )
    }
}

