//
//  DecodedQRCodeModel.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-29.
//

import Foundation

// MARK: - DecodedQRPayload
public struct DecodedQRPayload: Codable {
    let iss: String
    let nbf: Double
    let vc: Vc
}

// MARK: - Vc
struct Vc: Codable {
    let type: [String]
    let credentialSubject: CredentialSubject
}

// MARK: - CredentialSubject
struct CredentialSubject: Codable {
    let fhirVersion: String
    let fhirBundle: FhirBundle
}

// MARK: - FhirBundle
struct FhirBundle: Codable {
    let resourceType, type: String
    let entry: [Entry]
}

// MARK: - Entry
struct Entry: Codable {
    let fullURL: String
    let resource: Resource

    enum CodingKeys: String, CodingKey {
        case fullURL = "fullUrl"
        case resource
    }
}

// MARK: - Resource
struct Resource: Codable {
    let resourceType: String
    let name: [Name]?
    let birthDate, status: String?
    let vaccineCode: VaccineCode?
    let patient: Patient?
    let occurrenceDateTime: String?
    let performer: [Performer]?
    let lotNumber: String?
    let meta: Meta?
}

// MARK: - Meta
struct Meta: Codable {
    let security: [Security]?
}

// MARK: - Security
struct Security: Codable {
    let system: String?
    let code: String?
}

// MARK: - Name
struct Name: Codable {
    let family: String?
    let given: [String]?
}

// MARK: - Patient
struct Patient: Codable {
    let reference: String
}

// MARK: - Performer
struct Performer: Codable {
    let actor: Actor?
}

// MARK: - Actor
struct Actor: Codable {
    let display: String?
}

// MARK: - VaccineCode
struct VaccineCode: Codable {
    let coding: [Coding]
}

// MARK: - Coding
struct Coding: Codable {
    let system: String?
    let code: String?
}


extension DecodedQRPayload {
    func getName() -> String {
        guard let first = self.vc.credentialSubject.fhirBundle.entry.first,
              let nameModel = first.resource.name?.first else {
            return ""
        }
       
        var fullName = ""
        let familyName = nameModel.family ?? ""
        nameModel.given?.forEach { name in
            fullName += fullName == "" ? "\(name)" : " \(name)"
        }
        fullName = "\(fullName) \(familyName)"
        return fullName
    }
    
    func getBirthDate() -> String? {
        guard let first = self.vc.credentialSubject.fhirBundle.entry.first,
              let birthDate = first.resource.birthDate else {
            return nil
        }
        return birthDate
    }
}
