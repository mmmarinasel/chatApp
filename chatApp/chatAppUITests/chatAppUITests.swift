import XCTest
@testable import chatApp

class ChatAppUITests: XCTestCase {
    
    func testCheckScreenElements() throws {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars["Channels"].buttons["person"].tap()
        
        XCTAssertTrue(app.images["profileImageView"].exists)
        XCTAssertEqual(app.navigationBars["My profile"].staticTexts.matching(identifier: "My profile").count, 1)
        XCTAssertTrue(app.staticTexts["Edit"].exists)
        
        XCTAssertTrue(app.textFields["nameTextField"].exists)
        XCTAssertTrue(app.textViews["descriptionTextView"].exists)
    }
    
}
