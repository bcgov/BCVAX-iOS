//
//  JWKSIssuersTEST.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-15.
//

import Foundation
enum JWKSIssuers: String {
    static let allValues = [BC]
    case BC = "https://smarthealthcard.phsa.ca/v1/issuer/.well-known/jwks.json"
}
