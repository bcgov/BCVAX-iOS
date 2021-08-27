//
//  ScanResultModel.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-27.
//

import Foundation

enum VaccinationStatus {
    case Vaccinated
    case NotVaccinated
}

struct ScanResultModel {
    let name: String
    let status: VaccinationStatus
}
