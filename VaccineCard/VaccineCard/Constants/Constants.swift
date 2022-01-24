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
        
        struct CameraView {
            struct CameraCutout {
                static let fillLayerName = "cutout-fill-layer"
                static let bornerLayerName = "border-layer"
                static let imageTag = 978142
                
                static let colour = UIColor(hexString: "313132").cgColor
                static let opacity: Float = 0.7
                static let cornerRadius: CGFloat = 10
                
                static let logoSize: CGFloat = 60
                static let paddingBetweenLogoAndBox: CGFloat = 12
                
                static var width: CGFloat {
                    switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                    case .pad:
                        return 506
                    default:
                        return 247
                    } 
                }
                
                static var height: CGFloat {
                    switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                    case .pad:
                        return 469
                    default:
                        return 293
                    }
                }
            }
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
            static let title = "Please scan an official proof of vaccination"
            static let subtitle = "We need permission to access your camera to be able to scan an official proof of vaccination"
            static let buttonTitle = "Start Scanning"
            static let titleFont: UIFont = UIFont.init(name: "BCSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            static let subtitleFont: UIFont = UIFont.init(name: "BCSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
            static let buttonFont: UIFont = UIFont.init(name: "BCSans-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        
        
        struct ScanResult {
            static var titleFont: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-Bold", size: 27) ?? UIFont.systemFont(ofSize: 27, weight: .semibold)
                default:
                    return UIFont.init(name: "BCSans-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
                }
            }
           
            static var nameFont: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
                default:
                    return UIFont.init(name: "BCSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
                }
            }
            
            static var buttonFont: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
                default:
                    return UIFont.init(name: "BCSans-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
                }
            }
            
            static var cardTitleFont: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-Bold", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold)
                default:
                    return UIFont.init(name: "BCSans-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
                }
            }
            
            static var cardSubtitleFont: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-regular", size: 16) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
                default:
                    return UIFont.init(name: "BCSans-regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
                }
            }
        }
        struct Status {
            static var font: UIFont {
                switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                case .pad:
                    return UIFont.init(name: "BCSans-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22)
                default:
                    return UIFont.init(name: "BCSans-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22)
                }
            }
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
