//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-09-22.
//

import Foundation

public struct CodeValidationResult {
    public let status: CodeValidationResultStatus
    public let result: ScanResultModel?
}

public struct ScanResultModel {
    public let code: String
    public let issueDate: Double
    public let name: String
    public let birthdate: String
    public let status: ImmunizationStatus
    public let immunizations: [COVIDImmunizationRecord]
    public let payload: DecodedQRPayload
}

public struct COVIDImmunizationRecord {
    public let vaccineCode: String?
    public let date: String?
    public let provider: String?
    public let lotNumber: String?
    public let snomed: String?
}

public enum CodeValidationResultStatus {
    case ValidCode
    case InvalidCode
    case ForgedCode
    case MissingData
}

public enum ImmunizationStatus: String {
    case Fully = "fully"
    case Partially = "partially"
    case None = "none"
}
