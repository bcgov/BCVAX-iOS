//
//  String.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation

extension String {
    
    /// Decondes numeric code that is prefixed with 'shc:/' - coming from QR code
    /// - Parameter code: shc:/ followed by a numeric code
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
            print("Invalid Compact JSW: must have 3 base64 components separated by a dot")
            return nil
        }
        let header = parts[0]
        let payload = parts[1]
        let signature = parts[2]
        guard let decodedHeader: String = header.base64Decoded(),
              let decodedPayload: Data = payload.base64Decoded()
              // let decodedSignature = decodeBase64(string: signature)
        else {
            print("Invalid Compact JSW: Could not decode base64")
            return nil
        }
        
        return decodedPayload.decompressJSON()
    }
}

extension String {
    
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
    
    func base64Decoded() -> String? {
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
    
    func base64Decoded() -> Data? {
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
