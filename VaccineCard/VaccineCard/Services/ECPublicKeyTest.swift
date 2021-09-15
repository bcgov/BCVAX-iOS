//
//  ECPublicKeyTest.swift
//  VaccineCardTEST
//
//  Created by Amir Shayegh on 2021-09-14.
//

import Foundation
import JOSESwift

/**
 This file is only available in TEST Target
 */
extension VerificationService {
    static func keys() -> [ECPublicKey] {
        return Constants.JWKSPublic.prodKeys.map({ECPublicKey(crv: ECCurveType.P256, x: $0.x, y: $0.y)})
    }
    
}
