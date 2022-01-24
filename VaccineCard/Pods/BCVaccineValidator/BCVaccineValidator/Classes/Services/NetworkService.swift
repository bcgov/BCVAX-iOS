//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-05.
//

import Foundation
import Alamofire

class NetworkService {
    
    func getIssuers(url: String, completion: @escaping (Issuers?) -> Void) {
        guard ReachabilityService.shared.isReachable else {
            BCVaccineValidator.shouldUpdateWhenOnline = true
            return completion(nil)
        }
        AF.request(url, requestModifier: { $0.timeoutInterval = Constants.networkTimeout })
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: Issuers.self) { response in
                switch response.result {
                case .success(let issuers):
                    return completion(issuers)
                case .failure(let error):
#if DEBUG
                    print("Something went wrong: \(error)")
#endif
                    return completion(nil)
                }
            }
    }
    
    func getRules(completion: @escaping (VaccinationRules?) -> Void) {
        guard ReachabilityService.shared.isReachable else {
            BCVaccineValidator.shouldUpdateWhenOnline = true
            return completion(nil)
        }
        AF.request(Constants.JWKSPublic.rulesURL, requestModifier: { $0.timeoutInterval = Constants.networkTimeout })
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: VaccinationRules.self) { response in
                switch response.result {
                case .success(let rules):
                    return completion(rules)
                case .failure(let error):
#if DEBUG
                    print("Something went wrong: \(error)")
#endif
                    return completion(nil)
                }
            }
    }
    
    func getJWKS(forIssuer issuer: String, completion: @escaping (PublicKeys?) -> Void) {
        guard ReachabilityService.shared.isReachable else {
            BCVaccineValidator.shouldUpdateWhenOnline = true
            return completion(nil)
        }
        AF.request(issuer.addWellKnownJWKS_URLExtension(), requestModifier: { $0.timeoutInterval = Constants.networkTimeout })
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: PublicKeys.self) { response in
                switch response.result {
                case .success(let keys):
                    return completion(keys)
                case .failure(let error):
#if DEBUG
                    print("Something went wrong: \(error)")
#endif
                    return completion(nil)
                }
            }
    }
}
