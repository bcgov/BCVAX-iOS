//
//  PublicKeys.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-15.
//

import Foundation

struct PublicKeys: Codable {
    let keys: [Key]
}

struct Key: Codable {
    let kty, kid, use, alg: String
    let crv, x, y: String
}
