<img src="https://github.com/user-attachments/assets/052f80af-3597-4edf-83dd-8b5176af5ccc" alt="xcuitestrunner_logo" width="160" height="160">

# XCUITestAgent
AI-Based UI Test Runner for Xcode using LLMs

## Run UI Tests Using Natural Language Prompts  

XCUITestAgent enables you to execute UI tests by simply describing what needs to be tested—no coding required.  

An LLM-based agent intelligently conducts the test by continuously monitoring the app's state (debug information + screen content) and interacting with the UI. It will keep navigating and verifying until it determines whether the test has passed or failed.  

This approach is based on the principles outlined in the following article: [Read more here](https://hundredeni.app).

## Supported Interactions

XCUITestAgent, powered by LLMs, supports a wide range of UI interactions to automate your tests effectively. The following interactions are supported:

### 1. **Tapping**  
   The agent can simulate a tap on any UI element, such as buttons, links, or images. The element **does not** need to have an accessibility label or identifier!

   - **Example Interaction**: "Tap the 'Submit' button"
   - Supported UI elements: Buttons, images, links, etc.

### 2. **Text Input**  
   The agent can input text into text fields, text views, or other editable fields.

   - **Example Interaction**: "Enter 'Hello, World!' into the username field"
   - Supported UI elements: Text fields, text views, search bars, etc.

### 3. **Swipe Gestures**  
   The agent supports simulating swipe gestures to navigate through content, such as scrolling, interacting with swipe controls, etc.

   - **Example Interaction**: "Swipe to confirm the transaction"
   - Supported gestures: Left, right, up, and down swipes.

### 4. **Waiting**  
   The agent can wait for a specified condition to be met before proceeding with the next step. This is particularly useful for waiting for UI elements to appear, animations to finish, or transitions to complete.

   - **Example Interaction**: "Wait up to 10 seconds for the 'Welcome' label to appear"
   - Supported conditions: Element visibility, text appearance, specific time delays, etc.

### 5. **Terminating the Test**  
   The agent can determine the outcome of the test and automatically terminate it with either a success or failure result. This is based on whether the expected conditions have been met or not.

   - **Example Interaction**: "The test is successful if a star is visible on the screen"
   - The agent will fail or complete the test according to the criteria laid out.

These supported interactions allow for comprehensive and flexible test automation, enabling XCUITestAgent to perform a wide range of UI testing tasks.

## Supported LLM's

This implementation has built-in support for OpenAI's GPT-4o (API key required).

However, if you prefer to use a different LLM or model, you can easily integrate it by implementing the `LLMClient` protocol. This allows you to connect your preferred model and use it for test automation without needing to rely on OpenAI.

## Usage

Here's an example of how to create a basic UI test using an XCUITestAgent:

  ```swift
  import XCTest
  import XCUITestAgent

  class ExampleUITests: XCTestCase {
      private var agent: XCUITestAgent!

      override func setUp() {
          super.setUp()
          agent = XCUITestAgent(
              app: XCUIApplication(),
              client: OpenAIClient(apiKey: "INSERT API KEY")
          )
      }

      func testCanAccessExampleScreen() {
          agent.runTest("""
                  1) Select the home tab
                  2) On the home screen, select the example item
                  3) Ensure that the example details screen is shown
              """
          )
      }
  }
