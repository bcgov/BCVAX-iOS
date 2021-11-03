//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-13.
//

import Foundation
extension Date {
    
    func daysTo(future date: Date) -> Int? {
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: date, to: self).day else {
            return nil
        }
        if numberOfDays > 0 {
            return nil
        }
        return abs(numberOfDays)
    }
}
