//
//  DecoderService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-27.
//

import Foundation

class DecoderService {
    
    
    /// Decondes numeric code that is prefixed with 'shc:/' - coming from QR code
    /// - Parameter code: shc:/ followed by a numeric code
    public static func decode(code: String) -> String? {
        guard let compactjws = decodeNumeric(code: code) else {
            return nil
        }
        
        return decodeCompactJWS(string: compactjws)
    }
    
    private static func decodeNumeric(code: String) -> String? {
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
    
    private static func decodeCompactJWS(string: String) -> String? {
        let parts = string.components(separatedBy: ".")
        print(parts)
//        let base64Encoded = parts[1]
//
//        let decodedData = Data(base64Encoded: base64Encoded)!
//        let decodedString = String(data: decodedData, encoding: .utf8)!
//
//        print(decodedString)
        return ""
    }
}

extension Array {
    func chunks(size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
}
