//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-05.
//

import Foundation

struct Issuers: Codable {
    let participatingIssuers: [ParticipatingIssuer]

    enum CodingKeys: String, CodingKey {
        case participatingIssuers = "participating_issuers"
       
    }
}

struct ParticipatingIssuer: Codable {
    let iss: String
    let name: String
}
