//
//  DirectoryManager.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-10-01.
//

import Foundation

protocol DirectoryManager {}

extension DirectoryManager {

    // MARK: Private fuctions
    func createDirectoryIfDoesntExist(path: URL) {
        guard !directoryExists(path: path) else {return}
        do {
            try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
    }
    
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func directoryExists(path: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            _ = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            return true
        } catch {
            return false
        }
    }
}
