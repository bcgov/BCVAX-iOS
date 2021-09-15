//
//  DocumentDirectoryManager.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-15.
//

import Foundation

fileprivate extension String {
    func filePathSafeName() -> String {
        return self.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "/", with: "~")
    }
    func filePathSafeNameToURL() -> String {
        return "https://\(self.replacingOccurrences(of: "~", with: "/"))"
    }
}

class JWKSStorage {
    
    public static let shared = JWKSStorage()
    
    init() {
        seedIfneeded()
    }
    
    public func store(keys: PublicKeys, for issuer: String) -> Bool {
        // define a direcotry path
        // for example, it a directory named:
        // https:||smarthealthcard.phsa.ca|v1|issuer
        let issuerPath = getDirectory(for: issuer)
        // Create directory for the issuer (if one doesnt exist already)
        createDirectoryIfDoesntExist(path: issuerPath)
        // Verify that the directory exists - TODO: remove?
        guard directoryExists(path: issuerPath) else {return false}
        let filePath = issuerPath.appendingPathComponent("jwks.json")
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
    
    public func fetchKeys(for issuer: String, completion: @escaping(_ keys: PublicKeys?) -> Void) {
        let issuerPath = getDirectory(for: issuer)
        guard directoryExists(path: issuerPath) else {return completion(nil)}
        let filePath = issuerPath.appendingPathComponent("jwks.json")
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
    
    private func seedIfneeded() {
        // Grab stored tokens
        let stored = fetchAll()
        // If the number matches the number of trusted issuers, no seeding is needed
        guard stored?.count != JWKSIssuers.allValues.count else {return}
        // Otherwise seed truested issuers
        JWKSIssuers.allValues.forEach { issuer in
            seed(issuer: issuer)
        }
        /*
         Note: if there is a new version of the app with changed truested issuers,
         this will re-seed all issuers - keep seed data up to date with each upload.
         */
    }
    
    private func seed(issuer: JWKSIssuers) {
        #if DEBUG
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath ){
            for file in files {
                print(file)
            }
        }
        #endif
        // Get Path
        guard let bundledFilePath = Bundle.main.url(forResource: "\(issuer.rawValue.filePathSafeName())", withExtension: "") else {
            #if DEBUG
            print("Issuer JWKS is not bundled\n\(issuer.rawValue)")
            print("name should be \n\(issuer.rawValue.filePathSafeName())")
            #endif
            return
        }
        do {
            // Get data at path
            let data = try Data(contentsOf: bundledFilePath)
            // Decode
            let keys = try JSONDecoder().decode(PublicKeys.self, from: data)
            _ = store(keys: keys, for: issuer.rawValue)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    
    /// Fetch all stored jwks.json files for trusted issuers
    /// - Returns: 2d array of issuer : jwks.json
    public func fetchAll() -> [JWKSIssuers: PublicKeys]? {
        let documentsDirectory = documentDirectory().appendingPathComponent("jwks")
        guard directoryExists(path: documentsDirectory) else {return nil}
        do {
            let subDirectories = try FileManager.default.subpathsOfDirectory(atPath: documentsDirectory.path)
            #if DEBUG
            print(subDirectories)
            #endif
            var results: [JWKSIssuers: PublicKeys] = [JWKSIssuers: PublicKeys]()
            for subDirectory in subDirectories where JWKSIssuers.allValues.contains(where: {$0.rawValue.filePathSafeName() == subDirectory}) {
                let jwksPath = getDirectory(for: subDirectory).appendingPathComponent("jwks.json")
                do {
                    let data = try Data(contentsOf: jwksPath)
                    // Decode
                    let keys = try JSONDecoder().decode(PublicKeys.self, from: data)
                    if let issuerEnum = JWKSIssuers.init(rawValue: subDirectory.filePathSafeNameToURL()) {
                        results[issuerEnum] = keys
                    }
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
    // These are wrapper functions for swift's FileManager
    private func createDirectoryIfDoesntExist(path: URL) {
        guard !directoryExists(path: path) else {return}
        do {
            try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
    }
    
    private func getDirectory(for issuer: String) -> URL {
        let documentsDirectory = documentDirectory().appendingPathComponent("jwks")
        let dirPath = documentsDirectory.appendingPathComponent(issuer.filePathSafeName())
        return dirPath
    }
    
    private func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func directoryExists(path: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            _ = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            return true
        } catch {
            return false
        }
    }
}
