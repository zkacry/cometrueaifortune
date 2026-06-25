import Flutter
import UIKit
import XCTest

/// Runner application unit tests
class RunnerTests: XCTestCase {

  /// Test basic application initialization
  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

  /// Test Flutter engine initialization
  func testFlutterEngineInitialization() {
    let controller = FlutterViewController()
    XCTAssertNotNil(controller, "Flutter controller should be initialized")
  }
}
