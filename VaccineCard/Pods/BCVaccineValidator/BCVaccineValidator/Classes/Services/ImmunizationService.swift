import Foundation
fileprivate extension String {
    func vaxDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from:self)
    }
}
/// This class is responsible for determining what immunized means
class ImmunizationService {
    
    /// Returns the immunization status of the given payload
    /// - Parameters:
    ///   - payload: SMART QR card payload
    ///   - completion: Fully || Partially || None. if nil, no rules could be found for issuer.
    public func immunizationStatus(payload: DecodedQRPayload, completion: @escaping(_ status: ImmunizationStatus?) -> Void) {
        if BCVaccineValidator.enableRemoteRules {
            RulesManager.shared.getRulesFor(iss: payload.iss) { [weak self] result in
                guard let `self` = self, let rules = result else { return completion(nil)}
                completion(self.getImmunizationStatus(for: payload, using: rules))
            }
        } else {
            return completion(immunizationStatus(payload: payload))
        }
    }
    
    private func immunizationStatus(payload: DecodedQRPayload)-> ImmunizationStatus {
        let vaxes = payload.vc.credentialSubject.fhirBundle.entry
            .compactMap({$0.resource}).filter({$0.resourceType.lowercased() == "Immunization".lowercased()})
        let janssenCVX = Constants.CVX.janssen
        let oneDoseVaxes = vaxes.filter({$0.vaccineCode?.coding[0].code == janssenCVX})

      if (oneDoseVaxes.count > 0 || vaxes.count > 1) {
        return .Fully
      } else if (vaxes.count > 0) {
        return .Partially
      } else {
        return .None
      }
    }
    
    private func getImmunizationStatus(for payload: DecodedQRPayload, using rulesSet: RuleSet) -> ImmunizationStatus? {
        let payloadVaxes = payload.vc.credentialSubject.fhirBundle.entry
            .compactMap({$0.resource}).filter({$0.resourceType.lowercased() == "Immunization".lowercased()})
        
        var mrnType = 0
        var nrvvType = 0
        var winacType = 0
        
        var lastDoseDate: Date? = nil
        
        for vaccination in payloadVaxes where vaccination.occurrenceDateTime != nil && vaccination.occurrenceDateTime?.vaxDate() != nil {
            
            if let lastDose = lastDoseDate, let vaxDate = vaccination.occurrenceDateTime?.vaxDate() {
                if lastDose < vaxDate {
                    lastDoseDate = vaccination.occurrenceDateTime?.vaxDate()
                }
            } else {
                lastDoseDate = vaccination.occurrenceDateTime?.vaxDate()
            }
            
            let rule = rulesSet.vaccinationRules.filter({$0.cvxCode == vaccination.vaccineCode?.coding[0].code}).first
            if rule == nil {continue}
            let vaxRule = rule!
            
            let vaxRuleType: VaccinationType = VaccinationType(rawValue: vaxRule.type) ?? .NotSet
            switch vaxRuleType {
            case .NotSet:
                break
            case .Mrna:
                mrnType += vaxRule.ru
                if mrnType >= rulesSet.ruRequired {
                    let intervalHasPassed = intervalPassed(lastDoseDate: lastDoseDate!, dayRequired: rulesSet.daysSinceLastInterval, intervalRequired: rulesSet.intervalRequired)
                    if intervalHasPassed {
                        return .Fully
                    } else {
                        return .Partially
                    }
                }
                break
            case .NRVV:
                nrvvType += vaxRule.ru
                if nrvvType >= rulesSet.ruRequired {
                    let intervalHasPassed = intervalPassed(lastDoseDate: lastDoseDate!, dayRequired: rulesSet.daysSinceLastInterval, intervalRequired: rulesSet.intervalRequired)
                    if intervalHasPassed {
                        return .Fully
                    } else {
                        return .Partially
                    }
                }
                break
            case .WInac:
                winacType += vaxRule.ru
                if winacType >= rulesSet.ruRequired {
                    let intervalHasPassed = intervalPassed(lastDoseDate: lastDoseDate!, dayRequired: rulesSet.daysSinceLastInterval, intervalRequired: rulesSet.intervalRequired)
                    if intervalHasPassed {
                        return .Fully
                    } else {
                        return .Partially
                    }
                }
                break
            }
            if rulesSet.mixTypesAllowed && (mrnType + nrvvType + winacType >= rulesSet.mixTypesRuRequired) {
                let intervalHasPassed = intervalPassed(lastDoseDate: lastDoseDate!, dayRequired: rulesSet.daysSinceLastInterval, intervalRequired: rulesSet.intervalRequired)
                if intervalHasPassed {
                    return .Fully
                } else {
                    return .Partially
                }
            }
        }
        
        if mrnType > 0 || winacType > 0 || nrvvType > 0 {
            return .Partially
        }
        return .None
    }
    
    func intervalPassed(lastDoseDate: Date, dayRequired: Int, intervalRequired: Bool) -> Bool {
        if !intervalRequired {
            return true
        }
        return lastDoseDate.daysTo(future: Date()) ?? 0 >= dayRequired
    }
}
