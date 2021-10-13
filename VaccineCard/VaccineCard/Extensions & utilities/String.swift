//
//  String.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation
import UIKit

extension String {    
    /// This method returns height of a string with specific `width` and `font`
    /// - Parameter width: Width of the view where string has to be displayed
    /// - Parameter font: Font of the view where string has to be displayed
    func heightForView(font:UIFont, width:CGFloat)  -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: [.font: font],
                                             context: nil)
        return ceil(boundingRect.height)
                                             
    }
}
