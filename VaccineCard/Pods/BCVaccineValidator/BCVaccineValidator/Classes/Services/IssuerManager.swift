//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-05.
//

import Foundation

class IssuerManager: DirectoryManager {
    private var isUpdating = false
    
    static let shared = IssuerManager()
    
    private init() {
        seedOrUpdateIfNeeded()
    }
    
    public func getIssuers(completion: @escaping(_ issuers: Issuers?)->Void) {
        seedOrUpdateIfNeeded()
        return completion(fetchLocalIssuers() ?? seedIssuers())
    }
    
    private func seedOrUpdateIfNeeded() {
        if fetchLocalIssuers() == nil {
#if DEBUG
            print("Seeding issuers")
#endif
            // need to seed
            let _ = seedIssuers()
            updateIssuers()
        } else if
            let expierdAt = UserDefaults.standard.object(forKey: Constants.UserDefaultKeys.issuersTimeOutKey) as? Date {
            if Date() > expierdAt {
                updateIssuers()
            }
        } else {
            updateIssuers()
        }
    }
    
    func updateIssuers() {
        if isUpdating || !BCVaccineValidator.enableRemoteRules {return}
        isUpdating = true
#if DEBUG
        print("Updating issuers")
#endif
        let networkService = NetworkService()
        networkService.getIssuers(url: Constants.JWKSPublic.issuersListUrl) { result in
            guard let issuers = result else {
                self.isUpdating = false
                return
            }
            self.store(issuers: issuers)
            self.updatedIssuers(issuers: issuers, exipersInMinutes: Constants.DataExpiery.defaultIssuersTimeout)
            self.isUpdating = false
        }
    }
    
    private func updatedIssuers(issuers: Issuers, exipersInMinutes: Double) {
        let defaults = UserDefaults.standard
        let now = Date()
        defaults.set(now.addingTimeInterval(_: exipersInMinutes * 60), forKey: Constants.UserDefaultKeys.issuersTimeOutKey)
#if DEBUG
        print("Updated issuers")
#endif
        
        Notification.Name.issuersUpdated.post(object: issuers)
    }
    
    private func store(issuers: Issuers) {
        let path = pathForIssuersFile()
        do {
            // Convert struct to data
            let data = try JSONEncoder().encode(issuers)
            // write
            try data.write(to: path)
            return
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    private func seedIssuers() -> Issuers? {
        // Get Path
        guard let bundledFilePath = BCVaccineValidator.resourceBundle.url(forResource: Constants.Directories.issuers.fileName, withExtension: "") else {
#if DEBUG
            print("\n\n**\n\nIssuers file is not bundled")
#endif
            return nil
        }
        do {
            // Get data at path
            let data = try Data(contentsOf: bundledFilePath)
            // Decode
            let issuers = try JSONDecoder().decode(Issuers.self, from: data)
            store(issuers: issuers)
            return issuers
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func fetchLocalIssuers() -> Issuers? {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.issuers.directoryName)
        guard directoryExists(path: documentsDirectory) else {return nil}
        let issuersFilePath = documentsDirectory.appendingPathComponent(Constants.Directories.issuers.fileName)
        
        do {
            let data = try Data(contentsOf: issuersFilePath)
            let issuers = try JSONDecoder().decode(Issuers.self, from: data)
            return issuers
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func pathForIssuersFile() -> URL {
        let documentsDirectory = documentDirectory().appendingPathComponent(Constants.Directories.issuers.directoryName)
        createDirectoryIfDoesntExist(path: documentsDirectory)
        let dirPath = documentsDirectory.appendingPathComponent(Constants.Directories.issuers.fileName)
        return dirPath
    }
}
