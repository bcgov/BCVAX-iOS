//
//  String.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation
import UIKit

extension String {
    
    /// Decondes numeric code that is prefixed with 'shc:/' - coming from QR code
    /// returns nil if string is not valid
    /// - Returns: DecodedQRPayload model containing data
    public func decodeSMART() -> DecodedQRPayload? {
        guard let compactjws = decodeNumeric(code: self) else {
            return nil
        }
        
        return decodeCompactJWS(string: compactjws)
    }
    
    fileprivate func decodeNumeric(code: String) -> String? {
        if let range = code.range(of: "shc:/") {
            let numericCode = String(code[range.upperBound...])
            let jwsNumeric = numericCode.chunks(size: 2)
            var uint16s: [UInt16] = []
            jwsNumeric.forEach { pair in
                if let pairInt = Int(pair),
                   let binInt = Int(String(pairInt, radix: 10)),
                   let uint16: UInt16 = UInt16(String(binInt + 45))
                   {
                        uint16s.append(uint16)
                }
            }
            if uint16s.isEmpty {
                return nil
            }
            let decodedJWS = String(utf16CodeUnits: uint16s, count: uint16s.count)
            return decodedJWS
        } else {
            return nil
        }
    }
    
    fileprivate func decodeCompactJWS(string: String) -> DecodedQRPayload? {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 3 else {
            print("Invalid Compact JWS: must have 3 base64 components separated by a dot")
            return nil
        }
        let header = parts[0]
        let payload = parts[1]
        guard let decodedHeader: String = header.base64Decoded(),
              let decodedPayload: Data = payload.base64Decoded()
        else {
            print("Invalid Compact JWS: Could not decode base64")
            return nil
        }
        print(decodedHeader)
        // TODO: Perform Decompression based on hedader data.
        return decodedPayload.decompressJSON()
    }
    
    fileprivate func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
    
    fileprivate func base64Decoded() -> String? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = self.padding(toLength: self.count + 4 - remainder,
                              withPad: "=",
                              startingAt: 0)
        }
        guard let d = Data(base64Encoded: st, options: .ignoreUnknownCharacters) else{
            return nil
        }
        return String(data: d, encoding: .utf8)
    }
    
    fileprivate func base64Decoded() -> Data? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = self.padding(toLength: self.count + 4 - remainder,
                              withPad: "=",
                              startingAt: 0)
        }
         return Data(base64Encoded: st, options: .ignoreUnknownCharacters)
    }
}


extension String {
    func heightForView(font:UIFont, width:CGFloat)-> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self

        label.sizeToFit()
        return label.frame.height
    }
    
}
