//
//  Constants.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation
import UIKit

struct Constants {
    struct Strings {
        static let vaccinationStatusHeader = "Covid-19 Vaccination Status Validation"
        static let scanAgain = "Scan Again"
        
        struct Errors {
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
        
        struct QRCodeHighlighter {
            static let tag = 72192376
            static let cornerRadius: CGFloat = Constants.UI.Theme.cornerRadius
            static let borderWidth: CGFloat = 3
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
        
        struct Status {
            static let font = UIFont.systemFont(ofSize: 22)
            static let textColor = UIColor.white
            
            
            // MARK: Status Colours
            struct fullyVaccinated {
                static let color = UIColor(hexString: "#2e8540")
                static let cardTitle = "Vaccinated"
                static let cardSubtitle = "British Columbia Official Result"
            }
            struct partiallyVaccinated {
                static let color = UIColor(hexString: "#3f5986")
                static let cardTitle = "Partically Vaccinated"
                static let cardSubtitle = "British Columbia Official Result"
            }
            
            struct notVaccinated {
                static let color = UIColor(hexString: "#d44f4f")
                static let cardTitle = "Not Vaccinated"
                static let cardSubtitle = "British Columbia Official Result"
            }
            
        }
        
        struct Banner {
            static let tag = 232213
            static let displayDuration: Double = 2.0 // seconds
            static let backgroundColor = Constants.UI.Theme.primaryColor
            static let labelColor = Constants.UI.Theme.primaryConstractColor
            static let labelFont = UIFont.systemFont(ofSize: 14)
            static let labelPadding: CGFloat = 8
            static let containerPadding: CGFloat = 16
        }
    }
}
