//
//  AccessibilityConstants.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-14.
//

import Foundation

struct AccessibilityLabels {
    
    struct OnBoarding {
        static let onboardingView = "On Boarding View"
        static let startScanningButton = "Allow Camera Access" // Constants.Strings.onBoarding.buttonTitle
        static let title = "BC Vaccine Card Verifier" // Constants.Strings.onBoarding.title
        static let subtitle = "Businesses can scan official digital or paper BC vaccine cards" // Constants.Strings.onBoarding.subtitle
        static let phoneImage = "Phone Image"
    }
    
    struct scannerView {
        static let cameraView = "Camera Screen"
        static let turnOnFlash = "Turn on torch light"
        static let turnOffFlash = "Turn off torch light"
    }
    
    struct ScanResultView {
        static let view = "Immunization staus"
        static let titleLabel = "BC Vaccine Card Verifier" // Constants.Strings.vaccinationStatusHeader
        static let scanButton = "Scan Next" // Constants.Strings.scanAgain
    }
    
    
}

