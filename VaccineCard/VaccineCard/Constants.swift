//
//  Constants.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation
import UIKit

struct Constants {
    struct UI {
        struct Theme {
            static let primaryColor = UIColor(hexString: "#003366")
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
            
            static let vaccinatedColor = UIColor(hexString: "2e8540")
        }
    }
}
