struct XCUITestAgentSystemPrompt {
    enum ResponseFormat: String {
        case json = "JSON"
    }

    struct ResponseExample {
        public let description: String
        public let response: String
    }

    func make(
        responseFormat: ResponseFormat,
        responseExamples: [ResponseExample],
        additionalResponseDescription: String? = nil
    ) -> String {
        var prompt = """
            You are an agent testing software applications. You are given a series of instructions on the test to perform along with a snapshot of the current state of the software application (screenshot and debug view hierarchy). You must respond with the next action to take to continue on with the test. The response must be in the following \(responseFormat.rawValue) format.
        """
        responseExamples.forEach { example in
            prompt += """
            \n
            \(example.description):
            \(example.response)
        """
        }
        if let additionalResponseDescription {
            prompt += """
            \n
            \(additionalResponseDescription)
        """
        }
        return prompt
    }
}
