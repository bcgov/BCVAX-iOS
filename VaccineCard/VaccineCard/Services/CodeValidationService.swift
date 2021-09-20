//
//  CodeValidationService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation


enum CodeValidationResultStatus {
    case ValidCode
    case InvalidCode
    case ForgedCode
    case MissingData
}

struct CodeValidationResult {
    let status: CodeValidationResultStatus
    let result: ScanResultModel?
}

enum ImmunizationStatus: String {
    case fully = "fully"
    case partially = "partially"
    case none = "none"
}

class CodeValidationService {
    static let shared = CodeValidationService()
    
    public func validate(code: String, completion: @escaping (CodeValidationResult)->Void) {
        // Move to a background thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            guard let compactjws = self.decodeNumeric(code: code) else {
                return completion(CodeValidationResult(status: .InvalidCode, result: nil))
            }
            
            guard let decodedJWS: Data = self.decodeCompactJWSPayload(string: compactjws) else {
                return completion(CodeValidationResult(status: .InvalidCode, result: nil))
            }
            
            guard let payload = decodedJWS.decompressJSON() else {
                return completion(CodeValidationResult(status: .InvalidCode, result: nil))
            }
            
            guard let header = self.getJWSHeader(from: compactjws) else {
                return completion(CodeValidationResult(status: .InvalidCode, result: nil))
            }
            
            guard let name = payload.getName() else {
                return completion(CodeValidationResult(status: .MissingData, result: nil))
            }
            
            let status = ImmunizationService.immunizationStatus(payload: payload)
            
            if status == .none {
                return completion(CodeValidationResult(status: .InvalidCode, result: nil))
            }
            
            let result = ScanResultModel(name: name, status: status)
            
            VerificationService.shared.verify(jwkSigned: compactjws, iss: payload.iss, kid: header.kid) { isVerified in
                guard isVerified else {
                    return completion(CodeValidationResult(status: .ForgedCode, result: nil))
                }
                return completion(CodeValidationResult(status: .ValidCode, result: result))
            }
        }
    }
    
    
    /// Decondes numeric code that is prefixed with 'shc:/' - coming from QR code
    /// returns nil if string is not valid
    /// - Returns: DecodedQRPayload model containing data
    public func decodeSMART(shcPayload: String) -> DecodedQRPayload? {
        guard let compactjws = decodeNumeric(code: shcPayload) else {
            return nil
        }
        
        return decodeCompactJWSPayload(string: compactjws)
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
    
    fileprivate func decodeCompactJWSPayload(string: String) -> DecodedQRPayload? {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 3 else {
            print("Invalid Compact JWS: must have 3 base64 components separated by a dot")
            return nil
        }
        let payload = parts[1]
        guard let decodedPayload: Data = payload.base64DecodedData()
        else {
            print("Invalid Compact JWS: Could not decode base64")
            return nil
        }
        return decodedPayload.decompressJSON()
    }
    
    fileprivate func decodeCompactJWSPayload(string: String) -> Data? {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 3 else {
            print("Invalid Compact JWS: must have 3 base64 components separated by a dot")
            return nil
        }
        let payload = parts[1]
        return payload.base64DecodedData()
    }
    
    fileprivate func getJWSHeader(from  string: String) -> QRHeader? {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 3 else {
            print("Invalid Compact JWS: must have 3 base64 components separated by a dot")
            return nil
        }
        let header = parts[0]
        guard let headerData = header.base64DecodedData() else {
            return nil
        }
        do {
            return try JSONDecoder().decode(QRHeader.self, from: headerData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
