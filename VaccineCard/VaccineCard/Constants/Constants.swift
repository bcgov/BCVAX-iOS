//
//  Constants.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation
import UIKit


struct Constants {
    static let dismissResultsAfterSeconds: Double = 10
    static let launchScreenExtension: Double = 2
    
    struct JWKSPublic {
        static let urlExtension = ".well-known/jwks.json"
    }
    
    struct CVX {
        static let janssen = "212"
    }
    
    struct Strings {
        static let vaccinationStatusHeader = "BC Vaccine Card Verifier"
        static let scanAgain = "Scan Next"
        
        struct shouldUpdate {
            static let title = "Please Update"
            static let message = "A new version of this app is available on the app store"
        }
        
        struct Errors {
            struct CameraAccessIsNecessary {
                static let title = "No Camera Access"
                static let message = "Camera access is necessary to use this app."
            }
            struct MultipleQRCodes {
                static let message = "There are multiple QR codes in view"
            }
            struct InvalidCode {
                static let message = "Invalid QR Code"
            }
            struct VideoNotSupported {
                static let title = "Unsupported Device"
                static let message = "Please use a device that supports video capture."
            }
            struct QRScanningNotSupported {
                static let title = "Unsupported Device"
                static let message = "Your device does not support QR code scanning."
            }
        }
    }
    
    struct UI {
        struct Theme {
            static let primaryColor = UIColor(hexString: "#003366")
            static let secondaryColor = UIColor(hexString: "#eea73b")
            static let primaryConstractColor = UIColor.white
            static let cornerRadius: CGFloat = 4
            static let animationDuration = 0.3
        }
        
        struct TorchButton {
            static let tag = 92133
            static let buttonSize: CGFloat = 42
        }
        
        struct QRCodeHighlighter {
            static let tag = 72192376
            static let cornerRadius: CGFloat = Constants.UI.Theme.cornerRadius
            static let borderWidth: CGFloat = 6
            static let borderColor = Constants.UI.Theme.secondaryColor.cgColor
            static let borderColorInvalid = UIColor.red.cgColor
        }
        
        struct LoadingIndicator {
            static let backdropTag = 45645676
            static let backdropColor = UIColor.black.withAlphaComponent(0.5)
            static let containerColor = UIColor.white
            static let containerSize: CGFloat = 70
            static let size: CGFloat = 30
        }
        
        struct onBoarding {
            static let tag = 3124145
            static let title = "BC Vaccine Card Verifier"
            static let subtitle = "Businesses can scan official digital or paper BC vaccine cards"
            static let buttonTitle = "Start Scanning"
            static let titleFont: UIFont = UIFont.init(name: "BCSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            static let subtitleFont: UIFont = UIFont.init(name: "BCSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
            static let buttonFont: UIFont = UIFont.init(name: "BCSans-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        
        struct Status {
            static let font: UIFont = UIFont.init(name: "BCSans-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22)
            static let textColor = UIColor.white
            
            
            // MARK: Status Colours
            struct fullyVaccinated {
                static let color = UIColor(hexString: "#2e8540")
                static let cardTitle = "Vaccinated"
                static let cardSubtitle = "British Columbia Official Result"
            }
            struct partiallyVaccinated {
                static let color = UIColor(hexString: "#3f5986")
                static let cardTitle = "Partially Vaccinated"
                static let cardSubtitle = "British Columbia Official Result"
            }
            
            struct notVaccinated {
                static let color = UIColor(hexString: "#b6b6b6")
                static let cardTitle = "No Records Found"
                static let cardSubtitle = "British Columbia Official Result"
            }
            
        }
        
        struct Banner {
            static let tag = 232213
            static let displayDuration: Double = 2.0 // seconds
            static let backgroundColor = Constants.UI.Theme.primaryColor
            static let labelColor = Constants.UI.Theme.primaryConstractColor
            static let labelFont: UIFont = UIFont.init(name: "BCSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            static let labelPadding: CGFloat = 8
            static let containerPadding: CGFloat = 16
        }
    }
}
