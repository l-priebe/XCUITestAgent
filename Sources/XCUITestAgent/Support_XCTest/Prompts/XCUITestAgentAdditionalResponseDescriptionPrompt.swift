import Foundation

struct XCUITestAgentAdditionalResponseDescriptionPrompt {
    func make() -> String {
        return """
            Explanation of the JSON properties:
            "description" a description of the actions to take. If a longer delay until next action is used, also mention this in the description.
            "actions" is an array (with at least one element) of actions to take. List multiple actions in the array if a simple action needs to be repeated, e.g. when entering keyboard input.
            "actionType" is an enum for type of action to take. can be "tap", "swipe", "enterText", "idle", "success" or "failure".
            "elementFrame" the frame (coordinates) of the element to tap as found in the debug view hierarchy (if action is tap, swipe or enterText).
            "text": the text to enter (if action is enterText).
            "swipeDirection": the direction to swipe towards (if action is swipe). can be "left", "right", "up" or "down".
            "delayUntilNextSequence" is the expected delay in seconds until next action sequence should be performed (if action is tap, swipe, enterText or idle), e.g. to take into account delays in presentation or loading states.
        """
    }
}
