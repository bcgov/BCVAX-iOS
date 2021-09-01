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
                let result = ScanResultModel(name: name, status: self.immunizationStatus(payload: model, checkDate: Date()))
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
    
    public func immunizationStatus(payload: DecodedQRPayload, checkDate: Date)-> ImmunizationStatus {
        var imms = payload.vc.credentialSubject.fhirBundle.entry
            .compactMap({$0.resource}).filter({$0.resourceType.lowercased() == "Immunization".lowercased()})
        
        if (imms.count < 1) {
            return .none
        }
        
        let janssenCode = "28951000087107"
        let dateFormat = "yyyy-MM-dd"
        
        // Sort by date vaccinated
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = dateFormat
        imms.sort { x, y in
            guard let xTimeString = x.occurrenceDateTime,
                  let xTime = dateFormatter.date(from: xTimeString) else {
                return false
            }
            guard let yTimeString = y.occurrenceDateTime,
                  let yTime = dateFormatter.date(from: yTimeString) else {
                return true
            }
            return xTime > yTime
        }
        
        let janssenImms = imms.filter({$0.vaccineCode?.coding[0].code == janssenCode})
        
        // 14 days or later after dose 1: partially immunized
        let oneDosePartially: Bool
        if let lastDoseDateString = imms[0].occurrenceDateTime,
           let lastDoseDate = dateFormatter.date(from: lastDoseDateString),
           let daysSinceLastDose = lastDoseDate.daysSince(past: checkDate)
        {
            oneDosePartially = daysSinceLastDose >= 14
        } else {
            oneDosePartially = false
        }
        
        // 14 days or later after Janssen vaccine dose: fully immunized
        let oneDoseFully: Bool
        if janssenImms.count > 0,
           let lastDoseDateString = janssenImms[0].occurrenceDateTime,
           let lastDoseDate = dateFormatter.date(from: lastDoseDateString),
           let daysSinceLastDose = lastDoseDate.daysSince(past: checkDate) {
            oneDoseFully = daysSinceLastDose >= 14
        } else {
            oneDoseFully = false
        }
        
        // Less than 7 days after dose 2: partially immunized
        let twoDosePartially = imms.count > 1
        
        let twoDoseFully: Bool
        if imms.count > 1,
           let lastDoseDateString = imms[1].occurrenceDateTime,
           let lastDoseDate = dateFormatter.date(from: lastDoseDateString),
           let daysSinceLastDose = lastDoseDate.daysSince(past: checkDate) {
            twoDoseFully = daysSinceLastDose >= 14
        } else {
            twoDoseFully = false
        }
        
        if oneDoseFully || twoDoseFully {
            return .fully
        } else if oneDosePartially || twoDosePartially {
            return .partially
        } else {
            return .none
        }
    }
}
