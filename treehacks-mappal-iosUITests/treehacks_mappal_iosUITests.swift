//
//  treehacks_mappal_iosUITests.swift
//  treehacks-mappal-iosUITests
//
//  Created by RYOKATO on 2019/03/28.
//  Copyright © 2019 mappal. All rights reserved.
//

import XCTest

class treehacks_mappal_iosUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOKButton() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let button = app.buttons["I am OK 😄"]
        XCTAssertTrue(button.isHittable)
        app.swipeLeft()
    }
    
    func testHelpButton() {
        let button = app.buttons["Help me 😱"]
        XCTAssertTrue(button.isHittable)
        app.swipeLeft()
    }

}
