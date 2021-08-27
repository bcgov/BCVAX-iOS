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
        }
        struct LoadingIndicator {
            static let backdropTag = 45645676
            static let backdropColor = UIColor.black.withAlphaComponent(0.5)
            static let containerColor = UIColor.white
            static let containerSize: CGFloat = 70
            static let size: CGFloat = 30
        }
        
        struct Field {
            static let textColor = UIColor.black
            static let textBackground = UIColor.white
            static let headerColor = UIColor.white
            static let font = UIFont.systemFont(ofSize: 14)
            static let headerFont = UIFont.systemFont(ofSize: 14)
        }
        
        struct Status {
            static let font = UIFont.systemFont(ofSize: 22)
            static let textColor = UIColor.white
            
            // MARK: Status Colours
            static let vaccinatedColor = UIColor(hexString: "#2e8540")
            static let notVaccinatedColor = UIColor.red
        }
    }
}
