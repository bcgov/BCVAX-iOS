//
//  ImmunizationService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-02.
//

import Foundation


/// This class is responsible for determining what immunized means
class ImmunizationService {
    public static func immunizationStatus(payload: DecodedQRPayload)-> ImmunizationStatus {
        let vaxes = payload.vc.credentialSubject.fhirBundle.entry
            .compactMap({$0.resource}).filter({$0.resourceType.lowercased() == "Immunization".lowercased()})
        let janssenCVX = Constants.CVX.janssen
        let oneDoseVaxes = vaxes.filter({$0.vaccineCode?.coding[0].code == janssenCVX})

      if (oneDoseVaxes.count > 0 || vaxes.count > 1) {
        return .fully
      } else if (vaxes.count > 0) {
        return .partially
      } else {
        return .none
      }
    }
}
