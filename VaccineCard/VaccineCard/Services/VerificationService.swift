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
    
    public static let shared = VerificationService()
    
    public func verify(jwkSigned: String, iss: String, kid: String, completion: @escaping (_ verified: Bool)-> Void) {
        // complete the issuer url by appending .well-known/jwks.json
        let issuer = "\(iss)/\(Constants.JWKSPublic.urlExtension)"
        // Fetch the stored jwks.json for the issuer
        fetchKeys(for: issuer) { keys in
            guard let key = keys.filter({$0.kid == kid}).first else {
                return completion(false)
            }
            return completion(self.verify(jwkSigned: jwkSigned, key: ECPublicKey(crv: ECCurveType.P256, x: key.x, y: key.y)))
        }
    }
    
    /// Veirfy the token signature
    /// - Parameters:
    ///   - jwkSigned: Signed token
    ///   - key: Public Key
    /// - Returns: Boolean indicating validity
    private func verify(jwkSigned: String, key: ECPublicKey) -> Bool {
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
    
    /// Fetch stored jwks.json
    /// - Parameters:
    ///   - issuer: issuer url
    ///   - completion: array of keys
    private func fetchKeys(for issuer: String, completion: @escaping(_ keys: [Key]) -> Void) {
        // Get list of allowed issuers
        let allowedIssuers: [String] = JWKSIssuers.allValues.map({$0.rawValue})
        
        // Verify that the issuer is allowed
        guard allowedIssuers.contains(issuer) else {
            print("** Invalid issuer: \(issuer)")
            return completion([])
        }
        
        // Fetch stored jwks.json from local storage
        JWKSStorage.shared.fetchKeys(for: issuer) { result in
            guard let publicKeys = result else {
                return completion([])
            }
            // return keys
            return completion(publicKeys.keys)
        }
        
    }
}
