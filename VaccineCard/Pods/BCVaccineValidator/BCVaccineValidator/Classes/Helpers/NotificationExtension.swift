//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-06.
//

import Foundation


public extension Notification.Name {
    static let issuersUpdated = Notification.Name("issuersUpdated")
    static let vaccinationRulesUpdated = Notification.Name("vaccinationRulesUpdated")
    static let keysUpdated = Notification.Name("keysUpdated")
    static let isReachable = Notification.Name("isReachable")
    static let isUnReachable = Notification.Name("isUnReachable")
  
    func post(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }

    @discardableResult
    func onPost(object: Any? = nil, queue: OperationQueue? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: using)
    }
}
