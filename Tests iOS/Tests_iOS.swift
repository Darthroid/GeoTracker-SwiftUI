//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import XCTest

class Tests_iOS: XCTestCase {
	
	var app: XCUIApplication!
	var uiInterruptionMonitor: NSObjectProtocol!
	
	let trackerName = "gpx_sample"
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		
		// Works for some system dialogs, but not for all.
		// So, it is better to avoid these dialogs at all, starting tests with the app already installed and all permissions already granted
		self.uiInterruptionMonitor = addUIInterruptionMonitor(withDescription: "close alerts") { (alert) -> Bool in
			if alert.buttons["Allow"].exists {
				alert.buttons["Allow"].tap()
			} else if alert.buttons["OK"].exists {
				alert.buttons["OK"].tap()
			}
			
			return true
		}
	}

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
	
	override func tearDown() {
		removeUIInterruptionMonitor(self.uiInterruptionMonitor)
		super.tearDown()
	}

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	// MARK: - Helper methods
	
	func wait(forElement element: XCUIElement, timeout: TimeInterval, handler: XCWaitCompletionHandler?) {
		let predicate = NSPredicate(format: "exists == 1")
		expectation(for: predicate, evaluatedWith: element)
		waitForExpectations(timeout: timeout, handler: handler)
	}
	
	func startApp(with params: [String]?) -> XCUIApplication {
		let application = XCUIApplication()
		if let params = params {
			application.launchArguments = params
		}
		application.launch()
		return application
	}
	
	func startApp() -> XCUIApplication  {
		return self.startApp(with: ["--uitesting"])
	}
	
	func startAppClean() -> XCUIApplication  {
		return self.startApp(with: ["--uitesting", "--uitesting-clean"])
	}
	
	// MARK: - Tests
	
	func test1_SelectTracker() throws {
		let app = self.startApp()
		let trackerlistTable = app.tables["TrackerList"]
		
		XCTAssertTrue(trackerlistTable.children(matching: .cell).count > 0)
		
		trackerlistTable.cells.element(boundBy: 0).tap()
		
		XCTAssertTrue(app.tables["PointList"].waitForExistence(timeout: 5))
		XCTAssertTrue(app.otherElements["MapView"].waitForExistence(timeout: 5))

		let cellsCount = app.tables["PointList"].children(matching: .cell).count
		XCTAssertTrue(cellsCount > 0)
	}
	
	func test2_ShareSheet() throws {
		let app = self.startApp()
		try? self.test1_SelectTracker()
				
		app.navigationBars[trackerName].buttons["ShareButton"].tap()
		XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: 5))
	
	}
	
	func test3_DeleteTracker() throws {
		let app = self.startApp()
		let trackerlistTable = app.tables["TrackerList"]
		let cellsCountBefore = trackerlistTable.children(matching: .cell).count
		XCTAssertTrue(cellsCountBefore > 0)
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
