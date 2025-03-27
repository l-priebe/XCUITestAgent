import Foundation

open class UITestAgent {
    private let retryLimit: Int = 3

    public let client: LLMClient
    public let responseMapper: LLMClientResponseMapper

    public let promptProvider: UITestAgentPromptProvider
    public let actionPerformer: UITestAgentActionPerformer

    private var actionHistory: [ActionSequence] = []
    private var retries = 0

    public init(
        client: LLMClient,
        responseMapper: LLMClientResponseMapper,
        promptProvider: UITestAgentPromptProvider,
        actionPerformer: UITestAgentActionPerformer
    ) {
        self.client = client
        self.responseMapper = responseMapper
        self.promptProvider = promptProvider
        self.actionPerformer = actionPerformer
    }

    public func runTest(_ testPrompt: String) {
        resetSession()

        // main test run loop
        var shouldContinue = true
        while shouldContinue {
            shouldContinue = performNextActionSequence(testPrompt: testPrompt)
        }
    }

    private func performNextActionSequence(testPrompt: String) -> Bool {
        // determine next sequence
        let nextActionSequence = nextAction(
            testPrompt,
            actionHistory: actionHistory
        )
        guard let lastAction = nextActionSequence.actions.last else {
            actionPerformer.perform(ActionSequence(
                description: "Unable to determine next action.",
                actions: [
                    .failure
                ]
            ))
            return false
        }

        // perform action sequence
        actionPerformer.perform(nextActionSequence)
        switch lastAction {
        case .success, .failure:
            return false
        default:
            return true
        }
    }

    private func resetSession() {
        actionHistory = []
        retries = 0
    }

    private func nextAction(_ testPrompt: String, actionHistory: [ActionSequence]) -> ActionSequence {
        do {
            let prompt = try promptProvider.makePrompt(
                testPrompt,
                actionHistory: actionHistory
            )
            let response = try performPromptSync(prompt: prompt)
            let action = try responseMapper.map(response: response)
            return action
        } catch let error {
            retries += 1
            guard retries < retryLimit else {
                return ActionSequence(
                    description: error.localizedDescription,
                    actions: [
                        .failure
                    ]
                )
            }
            return nextAction(
                testPrompt,
                actionHistory: actionHistory
            )
        }
    }

    private func performPromptSync(prompt: LLMClientPrompt) throws -> String {
        let responseSemaphore = DispatchSemaphore(value: 0)
        var response: String?
        var responseError: Error?
        Task {
            do {
                response = try await client.prompt(prompt)
            } catch let error {
                responseError = error
            }
            responseSemaphore.signal()
        }
        responseSemaphore.wait()
        guard let response else {
            throw responseError!
        }
        return response
    }
}
