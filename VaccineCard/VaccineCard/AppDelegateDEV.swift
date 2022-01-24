//
//  AppDelegateDev.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-11-04.
//

import Foundation
import UIKit
import BCVaccineValidator
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        FirebaseApp.configure()
        BCVaccineValidator.shared.setup(mode: .Dev)
        return true
    }
}
