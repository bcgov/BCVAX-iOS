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

class CodeValidationService {
    static let shared = CodeValidationService()
    
    public func validate(code: String, completion: @escaping (CodeValidationResult)->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            guard self.isVaccineCode(code: code) else {
                return completion(.notVaccineCard)
            }
            // TODO: Perform validation
            return completion(.valid)
        }
    }
    
    public func isVaccineCode(code: String) -> Bool {
        // TODO: validate
        return true
    }
}
