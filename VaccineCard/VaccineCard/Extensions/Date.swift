//
//  Date.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-31.
//

import Foundation
extension Date {
    
    /// Number of days since a past date
    /// - Parameter date: date in the future
    /// - Returns: number of days since paramenter. note: if date parameter is not in the future, returns nil
    func daysSince(past date: Date) -> Int? {
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: date, to: self).day else {
            return nil
        }
        if numberOfDays > 0 {
            return nil
        }
        return abs(numberOfDays)
    }
}
