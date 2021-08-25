//
//  ViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit

class ViewController: ScannerViewController {
    
    enum Segues: String {
        case showScanResult = "showScanResult"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == Segues.showScanResult.rawValue {
            // TODO: set values
        }
    }
    
    override func found(code: String) {
        view.startLoadingIndicator()
        CodeValidationService.shared.validate(code: code) { [weak self] status in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            if status != .notVaccineCard {
                self.performSegue(withIdentifier: Segues.showScanResult.rawValue, sender: self)
            } else {
                // TODO: show error banner
            }
            
        }
    }


}
