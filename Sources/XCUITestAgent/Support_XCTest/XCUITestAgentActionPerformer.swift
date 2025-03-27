import Foundation
import XCTest

public struct XCUITestAgentActionPerformer: UITestAgentActionPerformer{
    private let activityScrope: String = "XCUITestAgent"
    private let app: XCUIApplication
    
    public init(app: XCUIApplication) {
        self.app = app
    }
    
    public func perform(_ actionSequence: ActionSequence) {
        XCTContext.runActivity(named: "[\(activityScrope)]: \(actionSequence.description)") { _ in
            var shouldSleep = true
            for action in actionSequence.actions {
                switch action {
                case .tap(let elementFrame):
                    performTapInteraction(frame: elementFrame)
                case .enterText(let frame, let text):
                    performEnterTextInteraction(
                        frame: frame,
                        text: text
                    )
                case .swipe(let frame, let direction):
                    performSwipeInteraction(
                        frame: frame,
                        direction: direction
                    )
                case .idle:
                    break
                case .success:
                    shouldSleep = false
                case .failure:
                    XCTFail(actionSequence.description)
                }
            }
            if shouldSleep {
                let sleepDuration = UInt32(ceil(actionSequence.delayUntilNextSequence ?? 1))
                XCTContext.runActivity(named: "[\(activityScrope)]: Waiting \(sleepDuration) seconds...") { _ in
                    _ = sleep(sleepDuration)
                }
            }
        }
    }

    private func swipe(app: XCUIApplication, from: CGVector, to: CGVector) {
        app.coordinate(
            withNormalizedOffset: normalizedCoordinate(
                from,
                relativeTo: app
            )
        ).press(forDuration: 0.2, thenDragTo: app.coordinate(
            withNormalizedOffset: normalizedCoordinate(
                to,
                relativeTo: app
            )
        ))
    }
}

// MARK: - Interactions

extension XCUITestAgentActionPerformer {
    fileprivate func performTapInteraction(frame: CGRect) {
        guard
            let coordinate = vectorFromCenterOfFrame(frame)
        else {
            return
        }
        XCTContext.runActivity(named: "[\(activityScrope)]: Tapping coordinate \(coordinate)") { _ in
            app.coordinate(
                withNormalizedOffset: normalizedCoordinate(
                    coordinate,
                    relativeTo: app
                )
            ).tap()
        }
    }

    fileprivate func performEnterTextInteraction(frame: CGRect, text: String) {
        guard
            let coordinate = vectorFromCenterOfFrame(frame)
        else {
            return
        }
        XCTContext.runActivity(named: "[\(activityScrope)]: Entering text \(text) into element at \(coordinate)") { _ in
            let appRelativeCoordinate = app.coordinate(
                withNormalizedOffset: normalizedCoordinate(
                    coordinate,
                    relativeTo: app
                )
            )
            appRelativeCoordinate.tap()
            UIPasteboard.general.string = text
            sleep(1)
            appRelativeCoordinate.doubleTap()
            app.menuItems["Paste"].tap(timeout: 1)
        }
    }

    fileprivate func performSwipeInteraction(frame: CGRect, direction: SwipeDirection) {
        XCTContext.runActivity(named: "[\(activityScrope)]: Swiping \(direction) on element at \(frame)") { _ in
            switch direction {
            case .up:
                swipe(
                    app: app,
                    from: CGVector(dx: frame.midX, dy: frame.maxY),
                    to: CGVector(dx: frame.midX, dy: frame.minY)
                )
            case .down:
                swipe(
                    app: app,
                    from: CGVector(dx: frame.midX, dy: frame.minY),
                    to: CGVector(dx: frame.midX, dy: frame.maxY)
                )
            case .left:
                swipe(
                    app: app,
                    from: CGVector(dx: frame.maxX, dy: frame.midY),
                    to: CGVector(dx: frame.minX, dy: frame.midY)
                )
            case .right:
                swipe(
                    app: app,
                    from: CGVector(dx: frame.minX, dy: frame.midY),
                    to: CGVector(dx: frame.maxX, dy: frame.midY)
                )
            }
        }
    }
}

extension XCUIElement {
    fileprivate func tap(timeout: TimeInterval?) {
        if let timeout {
            XCTAssertTrue(waitForExistence(timeout: timeout))
        }
        if isHittable {
            tap()
        } else {
            coordinate(withNormalizedOffset: .zero).tap()
        }
    }
}

// MARK: - Coordinate mapping

fileprivate func vectorFromCenterOfFrame(_ frame: CGRect) -> CGVector? {
    // Calculate the center point in CGPoint form
    let centerX = Double(frame.minX + frame.width / 2)
    let centerY = Double(frame.minY + frame.height / 2)
    
    // Return the difference from the origin (0,0) as CGVector
    return CGVector(dx: centerX, dy: centerY)
}

fileprivate func normalizedCoordinate(_ coordinate: CGVector, relativeTo app: XCUIApplication) -> CGVector {
    let maxX = app.frame.maxX
    let maxY = app.frame.maxY
    return CGVector(
        dx: coordinate.dx / maxX,
        dy: coordinate.dy / maxY
    )
}

