//
//  String.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation
import UIKit

extension String {
    
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
    
    public func base64Decoded() -> String? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = st.padding(toLength: st.count + 4 - remainder,
                            withPad: "=",
                            startingAt: 0)
        }
        guard let d = Data(base64Encoded: st, options: .ignoreUnknownCharacters) else{
            return nil
        }
        return String(data: d, encoding: .utf8)
    }
    
    public func base64DecodedData() -> Data? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = st.padding(toLength: st.count + 4 - remainder,
                            withPad: "=",
                            startingAt: 0)
        }
        return Data(base64Encoded: st, options: .ignoreUnknownCharacters)
    }
}


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
