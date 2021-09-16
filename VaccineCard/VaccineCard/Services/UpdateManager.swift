//
//  UpdateManager.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-16.
//

import Foundation
import Alamofire

class UpdateManager {
    
    public static let shared = UpdateManager()
    
    func isUpdateAvailable(completion: @escaping (Bool)->Void) {
        guard let bundleInfo = Bundle.main.infoDictionary else {
            return completion(false)
        }
        
        guard let bundleId = bundleInfo["CFBundleIdentifier"] as? String,
              let currentVersion : String = bundleInfo["CFBundleShortVersionString"] as? String
        else {
            return completion(false)
        }
        
        AF.request("https://itunes.apple.com/lookup?bundleId=\(bundleId)").response { response in
            guard let data = response.data else {
                return completion(false)
            }
            do {
                
                if
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let results = json["results"] as? NSArray, let entry = results.firstObject as? NSDictionary,
                    let versionStore = entry["version"] as? String
                {
                    let arrayStore = versionStore.split(separator: ".")
                    let arrayLocal = currentVersion.split(separator: ".")
                    
                    if arrayLocal.count != arrayStore.count {
                        completion(true) // different versioning system
                    }
                    
                    // check each segment of the version
                    for (key, value) in arrayLocal.enumerated() {
                        if let intValue = Int(value), let intAppStore = Int(arrayStore[key]), intValue < intAppStore {
                            completion(true)
                        }
                    }
                }
                
                completion(false) // no new version or failed to fetch app store version
                
            } catch {
                #if DEBUG
                print(error.localizedDescription)
                #endif
                return completion(false)
            }
            
            
        }
    }
    
}
