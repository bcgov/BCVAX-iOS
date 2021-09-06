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
    
    static func verify(jwkSigned: String) -> Bool {
        return verify(jwkSigned: jwkSigned, key: getKey()!)
    }
    
    private static func verify(jwkSigned: String, key: ECPublicKey) -> Bool {
        do {
            let publicKey: SecKey = try key.converted(to: SecKey.self)
            //let verifier = Verifier(verifyingAlgorithm: .ES256, key: publicKey)
            let jws = try JWS(compactSerialization: jwkSigned)
            return jws.isValid(for: publicKey)
        } catch {
            print(error)
            return false
        }
        
    }

    private static func getKey() -> ECPublicKey? {
        let x = Constants.JWKSPublic.Dev.x
        let y = Constants.JWKSPublic.Dev.y
        return ECPublicKey(crv: ECCurveType.P256, x: x, y: y)
    }
}
