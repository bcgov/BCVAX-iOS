//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation

struct Constants {
    static let networkTimeout: Double = 5
    
    struct DataExpiery {
        static var defaultIssuersTimeout: Double { // Minutes
            switch BCVaccineValidator.mode {
            case .Prod:
                return 6 * 60 // 6 hours
            case .Test, .Dev:
                return 1
            }
        }
        
        static var detaultRulesTimeout: Double { // Minutes
            switch BCVaccineValidator.mode {
            case .Prod:
                return 6 * 60 // 6 hours
            case .Test, .Dev:
                return 1
            }
        }
    }
    
    struct JWKSPublic {
        static var issuersListUrl: String {
            switch BCVaccineValidator.mode {
            case .Prod:
                return "https://smarthealthcard.phsa.ca/v1/trusted/.well-known/issuers.json"
            case .Test:
                return "https://phsasmarthealthcard-dev.azurewebsites.net/v1/trusted/.well-known/issuers.json"
            case .Dev:
                return "https://phsasmarthealthcard-dev.azurewebsites.net/v1/trusted/.well-known/issuers.json"
            }
        }
        
        static var rulesURL: String {
            switch BCVaccineValidator.mode {
            case .Prod:
                return "https://smarthealthcard.phsa.ca/v1/covid19proof/.well-known/rules.json"
            case .Dev:
                return "https://ds9mwekyyprcy.cloudfront.net/rules.json"
            case .Test:
                return "https://phsasmarthealthcard-dev.azurewebsites.net/v1/Covid19Proof/.well-known/rules.json"
            }
        }
        
        static let wellKnownJWKS_URLExtension = ".well-known/jwks.json"
    }
    
    struct CVX {
        static let janssen = "212"
    }
    
    struct Directories {
        static let caceDirectoryName: String = "VaccineValidatorCache"
        
        struct issuers {
            static var fileName: String {
                switch BCVaccineValidator.mode {
                case .Prod:
                    return "issuers.json"
                case .Test, .Dev:
                    return "issuers-test.json"
                }
            }
            static let directoryName = "issuers"
        }
        
        struct rules {
            static var fileName: String {
                switch BCVaccineValidator.mode {
                case .Prod:
                    return "rules.json"
                case .Test:
                    return "rules-test.json"
                case .Dev:
                    return "rules-dev.json"
                }
            }
            static let directoryName = "rules"
        }
    }
    
    struct UserDefaultKeys {
        static let issuersTimeOutKey = "issuersTimeout"
        static let vaccinationRulesTimeOutKey = "vaccinationRulesTimeout"
    }
}
