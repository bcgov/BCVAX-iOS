//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-13.
//

import Foundation
class RulesManager: DirectoryManager {
    private var isUpdating = false
    
    static let shared = RulesManager()
    
    private init() {
        seedOrUpdateIfNeeded()
    }
    
    /// Get all vaccination rules that are currently stored.
    /// if rules need to be updated, the update will be triggered but this function wont wait for the update to complete.
    /// your next function call should have the updated rules
    /// - Parameter completion: all stored vaccination rules
    public func getRules(completion: @escaping(_ rules: VaccinationRules?)->Void) {
        seedOrUpdateIfNeeded()
        return completion(fetchLocalRules() ?? seedRules())
    }
    
    public func getRulesFor(iss issuer: String, completion: @escaping(_ rule: RuleSet?) -> Void) {
        getRules { rules in
            guard let rules = rules else {return completion(nil)}
            
            for rule in rules.ruleSet {
                let resolved = self.resolveRuleTarget(ruleTarget: rule.ruleTarget)
                if resolved.contains(issuer.removeWellKnownJWKS_URLExtension()) {
                    return completion(rule)
                }
            }
            return completion(nil)
        }
    }
    
    private func seedOrUpdateIfNeeded() {
        if fetchLocalRules() == nil {
#if DEBUG
            print("Seeding rules")
#endif
            // need to seed
            let _ = seedRules()
            updateRules()
        } else if
            let expierdAt = UserDefaults.standard.object(forKey: Constants.UserDefaultKeys.vaccinationRulesTimeOutKey) as? Date {
            if Date() > expierdAt {
                updateRules()
            }
        } else {
            updateRules()
        }
    }
    
    func updateRules() {
        if isUpdating || !BCVaccineValidator.enableRemoteRules {return}
        isUpdating = true
#if DEBUG
        print("Updating rules")
#endif
        let networkService = NetworkService()
        networkService.getRules { result in
            guard let rules = result else {
                self.isUpdating = false
                return
            }
            self.store(rules: rules)
            self.updatedRules(rules: rules, exipersInMinutes: Constants.DataExpiery.detaultRulesTimeout)
            self.isUpdating = false
        }
    }
    
    private func updatedRules(rules: VaccinationRules, exipersInMinutes: Double) {
        let defaults = UserDefaults.standard
        let now = Date()
        defaults.set(now.addingTimeInterval(_: exipersInMinutes * 60), forKey: Constants.UserDefaultKeys.vaccinationRulesTimeOutKey)
#if DEBUG
        print("Updated rules")
#endif
        
        Notification.Name.vaccinationRulesUpdated.post(object: rules)
    }
    
    private func store(rules: VaccinationRules) {
        let path = pathForRulesFile()
        do {
            // Convert struct to data
            let data = try JSONEncoder().encode(rules)
            // write
            try data.write(to: path)
            let ruleTargets = rules.ruleSet.map({$0.ruleTarget})
            store(rulesTargets: ruleTargets)
            return
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    private func seedRules() -> VaccinationRules? {
        // Get Path
        guard let bundledFilePath = BCVaccineValidator.resourceBundle.url(forResource: Constants.Directories.rules.fileName, withExtension: "") else {
#if DEBUG
            print("\n\n**\n\nRules file is not bundled\n\(Constants.Directories.rules.fileName)")
#endif
            return nil
        }
        do {
            // Get data at path
            let data = try Data(contentsOf: bundledFilePath)
            // Decode
            let rules = try JSONDecoder().decode(VaccinationRules.self, from: data)
            store(rules: rules)
            return rules
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func store(rulesTargets: [String]) {
        let displatchGroup = DispatchGroup()
        
        for ruleTarget in rulesTargets where !ruleTarget.contains(Constants.JWKSPublic.wellKnownJWKS_URLExtension) {
            displatchGroup.enter()
            var bundledFileURL: URL? = nil
            if let bundledFilePath = BCVaccineValidator.resourceBundle.url(forResource: ruleTarget.filePathSafeName(), withExtension: "") {
                bundledFileURL = bundledFilePath
            } else {
#if DEBUG
                print("\n\n**\n\nRule Target file is not bundled:\n\(ruleTarget)")
                print("Should be called \(ruleTarget.filePathSafeName())")
#endif
            }
            let networkService = NetworkService()
            networkService.getIssuers(url: ruleTarget) { result in
                let filePath = self.pathForRuleTargetFile(ruleTarget: ruleTarget.filePathSafeName())
                if let issuers = result {
                    do {
                        let dataAgain = try JSONEncoder().encode(issuers)
                        try dataAgain.write(to: filePath)
                    } catch {
                        print(error.localizedDescription)
                    }
                } else if let bundledFilePath = bundledFileURL, !FileManager.default.fileExists(atPath: filePath.path) {
                    do {
                        let data = try Data(contentsOf: bundledFilePath)
                        let issuers = try JSONDecoder().decode(Issuers.self, from: data)
                        let dataAgain = try JSONEncoder().encode(issuers)
                        try dataAgain.write(to: filePath)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        displatchGroup.notify(queue: .main) {
            return
        }
    }
    
    func resolveRuleTarget(ruleTarget: String) -> [String] {
        if ruleTarget.contains(Constants.JWKSPublic.wellKnownJWKS_URLExtension) {
            return [ruleTarget]
        } else if !ruleTarget.contains("issuers.json") {
            return [ruleTarget + Constants.JWKSPublic.wellKnownJWKS_URLExtension]
        }
        let filePath = self.pathForRuleTargetFile(ruleTarget: ruleTarget.filePathSafeName())
        do {
            let data = try Data(contentsOf: filePath)
            let issuers = try JSONDecoder().decode(Issuers.self, from: data)
            return issuers.participatingIssuers.map({$0.iss.removeWellKnownJWKS_URLExtension()})
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    private func fetchLocalRules() -> VaccinationRules? {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.rules.directoryName)
        guard directoryExists(path: documentsDirectory) else {return nil}
        let filePath = documentsDirectory.appendingPathComponent(Constants.Directories.rules.fileName)
        
        do {
            let data = try Data(contentsOf: filePath)
            let rules = try JSONDecoder().decode(VaccinationRules.self, from: data)
            return rules
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func fetchLocalRuleTarget(ruleTarget: String) -> Issuers? {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.rules.directoryName)
        guard directoryExists(path: documentsDirectory) else {return nil}
        let filePath = documentsDirectory.appendingPathComponent(ruleTarget)
        
        do {
            let data = try Data(contentsOf: filePath)
            let rt = try JSONDecoder().decode(Issuers.self, from: data)
            return rt
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func pathForRulesFile() -> URL {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.rules.directoryName)
        createDirectoryIfDoesntExist(path: documentsDirectory)
        let dirPath = documentsDirectory.appendingPathComponent(Constants.Directories.rules.fileName)
        return dirPath
    }
    
    private func pathForRuleTargetFile(ruleTarget: String) -> URL {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.rules.directoryName)
        createDirectoryIfDoesntExist(path: documentsDirectory)
        let dirPath = documentsDirectory.appendingPathComponent(ruleTarget.filePathSafeName())
        return dirPath
    }
}
