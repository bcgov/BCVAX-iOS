//
//  DocumentDirectoryManager.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-15.
//

import Foundation

class KeyManager: DirectoryManager {
    static let jwksFileName = "jwks.json"
    static let jwksKeysDirectory = "jwks"
    static let shared = KeyManager()
    
    init() {
        // Seed if needed
        seedIfneeded(completion: {
        })
    }
    
    func store(keys: PublicKeys, for issuer: String) -> Bool {
        // define a direcotry path
        // for example, it a directory named:
        // smarthealthcard.phsa.ca~v1~issuer
        let issuerPath = getDirectory(for: issuer.removeWellKnownJWKS_URLExtension().filePathSafeName().lowercased())
        // Create directory for the issuer (if one doesnt exist already)
        createDirectoryIfDoesntExist(path: issuerPath)
        // Verify that the directory exists - TODO: remove?
        guard directoryExists(path: issuerPath) else {return false}
        let filePath = issuerPath.appendingPathComponent(KeyManager.jwksFileName)
        do {
            // Convert struct to data
            let data = try JSONEncoder().encode(keys)
            // write
            try data.write(to: filePath)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func fetchKeys(for issuer: String, completion: @escaping(_ keys: PublicKeys?) -> Void) {
        let issuerPath = getDirectory(for: issuer)
        guard directoryExists(path: issuerPath) else {return completion(nil)}
        let filePath = issuerPath.appendingPathComponent(KeyManager.jwksFileName)
        do {
            // Get data at path
            let data = try Data(contentsOf: filePath)
            // Decode
            let keys = try JSONDecoder().decode(PublicKeys.self, from: data)
            return completion(keys)
        } catch {
            print(error.localizedDescription)
            return completion(nil)
        }
    }
    
    private func seedIfneeded(completion: @escaping ()->Void) {
        // Get list of issuers
        IssuerManager.shared.getIssuers { result in
            guard let issuers = result else {
                // It is highly unlikely that result is nil.
                print("Critical Error: No issuers found")
                return completion()
            }
            let storedKeys = self.fetchAllKeys(forIssuers: issuers.participatingIssuers)
            let displatchGroup = DispatchGroup()
            for issuer in issuers.participatingIssuers where storedKeys?[issuer.iss] == nil {
                displatchGroup.enter()
                self.seed(issuer: issuer.iss, completion: {
                    displatchGroup.leave()
                })
            }
            
            displatchGroup.notify(queue: .main) {
                return completion()
            }
        }
    }
    
    public func downloadKeys(forIssuers issuers: [String], completion: @escaping () -> Void) {
        let displatchGroup = DispatchGroup()
        for issuer in issuers {
            displatchGroup.enter()
            self.downloadKeys(forIssuer: issuer) { _ in
                displatchGroup.leave()
            }
        }
        
        displatchGroup.notify(queue: .main) {
            return completion()
        }
    }
    
    public func downloadKeys(forIssuer issuer: String, completion: @escaping (Bool) -> Void) {
        // Before downloading, verify that issuer is allowed
        IssuerManager.shared.getIssuers { result in
            guard
                let issuers = result,
                issuers.participatingIssuers.map({$0.iss}).contains(issuer)
            else {return completion(false)}
            // Download data
            let network = NetworkService()
            network.getJWKS(forIssuer: issuer) { result in
                guard let keys = result else {return completion(false)}
                // Store
                let _ = self.store(keys: keys, for: issuer)
    #if DEBUG
                print("Downloaded keys for \n\(issuer)")
    #endif
                Notification.Name.keysUpdated.post()
                return completion(true)
            }
        }
    }
    
    private func seed(issuer: String, completion: @escaping () -> Void) {
        // Get Path
        if let bundledFilePath = BCVaccineValidator.resourceBundle.url(forResource: issuer.filePathSafeName(), withExtension: "") {
            do {
                // Get data at path
                let data = try Data(contentsOf: bundledFilePath)
                // Decode
                let keys = try JSONDecoder().decode(PublicKeys.self, from: data)
                _ = store(keys: keys, for: issuer)
                return completion()
            } catch {
                print(error.localizedDescription)
#if DEBUG
            print("\n\n**\n\nIssuer JWKS is not bundled correctly.\n\(issuer)")
            print("name should be \n\(issuer.filePathSafeName())\ncheck the file\n\n")
#endif
                return completion()
            }
        } else {
            
#if DEBUG
            print("\n\n**\n\nIssuer JWKS is not bundled\n\(issuer)")
            print("name should be \n\(issuer.filePathSafeName())\n\n")
#endif
            // JWKS is not bundled, try downloading.
            downloadKeys(forIssuer: issuer, completion: {_ in
                return completion()
            })
        }
    }
    
    /// Fetch all stored jwks.json files for trusted issuers
    /// - Returns: 2d array of issuer : jwks.json
    func fetchAllKeys(forIssuers issuers:[ParticipatingIssuer]) -> [String: PublicKeys]? {
        let documentsDirectory = documentDirectory().appendingPathComponent(KeyManager.jwksKeysDirectory)
        guard directoryExists(path: documentsDirectory) else {return nil}
        do {
            let subDirectories = try FileManager.default.subpathsOfDirectory(atPath: documentsDirectory.path)
            var results: [String: PublicKeys] = [String: PublicKeys]()
            for subDirectory in subDirectories where issuers.contains(where: {$0.iss.filePathSafeName() == subDirectory}) {
                let jwksPath = getDirectory(for: subDirectory).appendingPathComponent(KeyManager.jwksFileName)
                do {
                    let data = try Data(contentsOf: jwksPath)
                    // Decode
                    let keys = try JSONDecoder().decode(PublicKeys.self, from: data)
                    results[subDirectory.filePathSafeNameToURL()] = keys
                } catch {
                    print(error.localizedDescription)
                    continue
                }
            }
            return results
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: Private fuctions
    private func getDirectory(for issuer: String) -> URL {
        let documentsDirectory = documentDirectory().appendingPathComponent(KeyManager.jwksKeysDirectory)
        let dirPath = documentsDirectory.appendingPathComponent(issuer.filePathSafeName())
        return dirPath
    }
}
