//
//  Array.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation

extension Array {
    func chunks(size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
