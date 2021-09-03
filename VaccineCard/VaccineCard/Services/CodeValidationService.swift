//
//  CodeValidationService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation

enum CodeValidationResult {
    case notVaccineCard
    case valid
    case invalid
}

enum ImmunizationStatus: String {
    case fully = "fully"
    case partially = "partially"
    case none = "none"
}


class CodeValidationService {
    static let shared = CodeValidationService()
    
    func decodeSMART(code: String)-> DecodedQRPayload? {
        return code.decodeSMART()
    }
    
    public func validate(code: String, completion: @escaping (ScanResultModel?)->Void) {
        // Move to a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            // Decode string and get name
            if let model = code.decodeSMART(), let name = model.getName() {
                let result = ScanResultModel(name: name, status: ImmunizationService.immunizationStatus(payload: model, checkDate: Date()))
                DispatchQueue.main.async {
                    // move back to main thread and return result
                    return completion(result)
                }
            } else {
                // Decodeing failed or could not get a name.
                DispatchQueue.main.async {
                    return completion(nil)
                }
            }
        }
    }
}
