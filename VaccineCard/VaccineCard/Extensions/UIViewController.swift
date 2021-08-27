//
//  UIViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-27.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
}
