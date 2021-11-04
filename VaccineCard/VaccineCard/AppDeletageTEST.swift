//
//  AppDeletageTest.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-11-04.
//

import Foundation
import UIKit
import BCVaccineValidator

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        BCVaccineValidator.shared.setup(mode: .Test)
        return true
    }
}
