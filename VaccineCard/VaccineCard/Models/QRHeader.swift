//
//  QRHeader.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-15.
//

import Foundation

struct QRHeader: Codable {
    let alg, zip, kid: String
}
