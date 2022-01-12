//
//  EncodableExtension.swift
//  BCVaccineValidator
//
//  Created by Amir on 2021-11-17.
//

import Foundation
import CommonCrypto

extension Encodable {
    
    func toString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
}
