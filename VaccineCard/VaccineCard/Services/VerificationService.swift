//
//  JWTService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-02.
//

import Foundation
import JOSESwift

/// This class is responsible for verifying the QR Code's (JWS) signature
class VerificationService {
    
    static func verify(jwkSigned: String, iss: String, kid: String) -> Bool {
        let issuer = "\(iss)/\(Constants.JWKSPublic.urlExtension)"
        let keys = keys()
        for key in keys where verify(jwkSigned: jwkSigned, key: key) {
            return true
        }
        return false
    }
    
    private static func verify(jwkSigned: String, key: ECPublicKey) -> Bool {
        do {
            let publicKey: SecKey = try key.converted(to: SecKey.self)
            
            
            let jws = try JWS(compactSerialization: jwkSigned)
            let isValid = jws.isValid(for: publicKey)
            /*
             The non depricated route returns false negatives when signature is valid:
             
            let verifier: Verifier = Verifier(verifyingAlgorithm: SignatureAlgorithm.PS256, key: key.keyType)!
            let isVlid = jws.isValid(for: verifier)
            */
            return isValid
        } catch {
            print(error)
            
            return false
        }
            
    }
}
