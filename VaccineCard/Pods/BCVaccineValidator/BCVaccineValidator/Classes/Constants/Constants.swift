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
        static var prodIssuers = "https://smarthealthcard.phsa.ca/v1/trusted/.well-known/issuers.json"
        static var devIssuers = "https://phsasmarthealthcard-dev.azurewebsites.net/v1/trusted/.well-known/issuers.json"
        static var testIssuers = "https://phsasmarthealthcard-dev.azurewebsites.net/v1/trusted/.well-known/issuers.json"
        static var issuersListUrl: String {
            switch BCVaccineValidator.mode {
            case .Prod:
                return prodIssuers
            case .Test:
                return testIssuers
            case .Dev:
                return devIssuers
            }
        }
        static var prodRules = "https://smarthealthcard.phsa.ca/v1/covid19proof/.well-known/rules.json"
        static var devRules = "https://ds9mwekyyprcy.cloudfront.net/rules.json"
        static var testRuls = "https://phsasmarthealthcard-dev.azurewebsites.net/v1/Covid19Proof/.well-known/rules.json"
        
        static var rulesURL: String {
            switch BCVaccineValidator.mode {
            case .Prod:
                return prodRules
            case .Dev:
                return devRules
            case .Test:
                return testRuls
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
