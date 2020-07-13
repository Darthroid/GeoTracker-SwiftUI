//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import XCTest

class Tests_iOS: XCTestCase {
	
	private func app() -> XCUIApplication {
		let app = XCUIApplication()
		app.launch()
		
		return app
	}

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testSelectTracker() throws {
		let app = self.app()
		let trackerlistTable = app.tables["TrackerList"]
		
		XCTAssertTrue(trackerlistTable.children(matching: .cell).count > 0)
		
		trackerlistTable.cells.element(boundBy: 0).tap()
		
		XCTAssertTrue(app.tables["PointList"].waitForExistence(timeout: 5))
		XCTAssertTrue(app.otherElements["MapView"].waitForExistence(timeout: 5))

		let cellsCount = app.tables["PointList"].children(matching: .cell).count
		XCTAssertTrue(cellsCount > 0)
	}
	
	func testDeleteTracker() throws {
		let app = self.app()
		let trackerlistTable = app.tables["TrackerList"]
		let cellsCountBefore = trackerlistTable.children(matching: .cell).count
		let cell = trackerlistTable.cells.element(boundBy: 0)
		
		cell.swipeLeft()
		trackerlistTable.buttons["Delete"].tap()
		
		let cellsCountAfter = trackerlistTable.children(matching: .cell).count
		
		XCTAssertTrue(cellsCountBefore > cellsCountAfter)
	}

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
