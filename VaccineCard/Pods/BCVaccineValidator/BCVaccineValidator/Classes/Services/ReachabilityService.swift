//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-06.
//

import Foundation
import Alamofire

class ReachabilityService {
    
    public static let shared = ReachabilityService()
    
    private let manager = NetworkReachabilityManager()
    public var isReachable: Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }
    
    private init() {
        startRechability()
        
    }
    
    private func startRechability() {
        manager?.startListening(onUpdatePerforming: {networkStatusListener in
            switch networkStatusListener {
            case .notReachable:
                self.whenUnreachable()
            case .reachable(.ethernetOrWiFi):
                self.whenReachable()
            case .reachable(.cellular):
                self.whenReachable()
            case .unknown:
                print("unknown connection status")
            }
        })
    }
    
    private func whenReachable() {
        Notification.Name.isReachable.post()
    }
    
    private func whenUnreachable() {
        Notification.Name.isUnReachable.post()
    }
}
