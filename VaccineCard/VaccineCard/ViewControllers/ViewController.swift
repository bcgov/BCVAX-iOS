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
    
    private var result: ScanResultModel? = nil
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
           id == Segues.showScanResult.rawValue,
           let destination = segue.destination as? ScanResultViewController,
           let result = result
           {
            // Disable swipe to dismiss
            if #available(iOS 13.0, *) {
                destination.isModalInPresentation = true
            } else {
                destination.modalPresentationStyle = .fullScreen
            }
            // Set values on result controller
            destination.setup(model: result) { [weak self] in
                guard let `self` = self else {return}
                // On close, Dismiss results and start capture session
                destination.dismiss(animated: true, completion: { [weak self] in
                    guard let `self` = self else {return}
                    self.captureSession?.startRunning()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                       
//                    }
                })
                
            }
        }
    }
    
    // MARK: Class Functions
    
    /// Function called when a QR code is found
    /// - Parameter code: QR code string
    override func found(code: String) {
        print(code)
        view.startLoadingIndicator()
        // Validate
        CodeValidationService.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            guard let res = result else {
                // show an error
                return
            }
            self.result = res
            self.showResult()
        }
    }
    
    /// Show results of QR scan
    func showResult() {
        self.performSegue(withIdentifier: Segues.showScanResult.rawValue, sender: self)
    }
    
    
}
