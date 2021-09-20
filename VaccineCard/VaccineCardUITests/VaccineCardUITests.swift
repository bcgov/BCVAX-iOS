//
//  VaccineCardUITests.swift
//  VaccineCardUITests
//
//  Created by Amir Shayegh on 2021-09-08.
//

import XCTest
@testable import VaccineCard

class VaccineCardUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testCurrentUI() {
        let app = XCUIApplication()
        let onBoarding: XCUIElement? = app.otherElements[AccessibilityLabels.OnBoarding.onboardingView]
        let cameraView: XCUIElement? = app.otherElements[AccessibilityLabels.scannerView.cameraView]
        let resultView: XCUIElement? = app.otherElements[AccessibilityLabels.ScanResultView.view]
        if let cameraPreviwView = cameraView {
            testCameraView()
        } else if let onBoardingView = onBoarding {
            let title = onBoardingView.staticTexts[AccessibilityLabels.OnBoarding.title]
            let subtitle = onBoardingView.staticTexts[AccessibilityLabels.OnBoarding.subtitle]
            let startButton = onBoardingView.buttons[AccessibilityLabels.OnBoarding.startScanningButton]
            XCTAssertTrue(title.exists)
            XCTAssertTrue(subtitle.exists)
            XCTAssertTrue(startButton.exists)
            allowCameraAccess()
        } else if let scanResult = resultView  {
            
        } else {
            XCTAssert(false)
        }
    }
    
    func testOnBoardingScreen() {
        let app = XCUIApplication()
        let onBoarding = app.otherElements[AccessibilityLabels.OnBoarding.onboardingView]
        if let onBoardingView = onBoarding {
            let title = onBoardingView.staticTexts[AccessibilityLabels.OnBoarding.title]
            let subtitle = onBoardingView.staticTexts[AccessibilityLabels.OnBoarding.subtitle]
            let startButton = onBoardingView.buttons[AccessibilityLabels.OnBoarding.startScanningButton]
            XCTAssertTrue(title.exists)
            XCTAssertTrue(subtitle.exists)
            XCTAssertTrue(startButton.exists)
            allowCameraAccess()
        } else {
            XCTAssert(false)
        }
    }
    
    func testCameraView() {
        sleep(1)
        let app = XCUIApplication()
        let cameraView = app.otherElements[AccessibilityLabels.scannerView.cameraView]
        XCTAssertTrue(cameraView.exists)
        let flashOnButton = app.buttons[AccessibilityLabels.scannerView.turnOnFlash]
        XCTAssertTrue(flashOnButton.exists)
        flashOnButton.tap()
        sleep(1)
        let flashOffButton = app.buttons[AccessibilityLabels.scannerView.turnOffFlash]
        XCTAssertTrue(flashOffButton.exists)
        flashOffButton.tap()
        sleep(1)
        XCTAssertTrue(flashOnButton.exists)
    }
    
    func testScanResultView() {
        sleep(1)
        
        let app = XCUIApplication()
        
        let immunizationStausElement = app.otherElements["Immunization staus"]
        immunizationStausElement.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Scan Next"]/*[[".otherElements[\"Immunization staus\"].buttons[\"Scan Next\"]",".buttons[\"Scan Next\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["BC Vaccine Card Verifier"]/*[[".otherElements[\"Immunization staus\"].staticTexts[\"BC Vaccine Card Verifier\"]",".staticTexts[\"BC Vaccine Card Verifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let element = immunizationStausElement.children(matching: .other).element(boundBy: 1)
        element.tap()
        element.children(matching: .other).element.tap()
                    
    }

    
    func allowCameraAccess() {
        XCUIApplication().buttons[AccessibilityLabels.OnBoarding.startScanningButton].tap()
        sleep(2)
        let alert = XCUIApplication().alerts["“BC Vaccine Card Verifier” Would Like to Access the Camera"].scrollViews.otherElements
        alert.buttons["OK"].tap()
    }
    
    func denyCameraAceess() {
        let app = XCUIApplication()
        app.buttons[AccessibilityLabels.OnBoarding.startScanningButton].tap()
        app.alerts["“BC Vaccine Card Verifier” Would Like to Access the Camera"].scrollViews.otherElements.buttons["Don’t Allow"].tap()
    }
    
}

