//
//  JWTService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-02.
//

import Foundation
import SwiftJWT

private struct ClaimsModel: Claims {
    let iss: String
    let sub: String
    let exp: Date
}

class JWTService {
    static func verify(key: Data, signedJWT: String) -> Bool {
        let jwtVerifier = JWTVerifier.es256(publicKey: key)
        return JWT<ClaimsModel>.verify(signedJWT, using: jwtVerifier)
    }
}
