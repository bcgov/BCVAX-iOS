//
//  ScanResultViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit

class ScanResultViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusContainer: UIView!
    
    // MARK: Variables
    private var onClose: (()->(Void))? = nil
    private var model: ScanResultModel? = nil
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setData()
    }
    
    // MARK: Outlet Actions
    @IBAction func closeButtonAction(_ sender: Any) {
        dimissPage()
    }
    
    @IBAction func scanButtonAction(_ sender: Any) {
        dimissPage()
    }
    
    private func dimissPage() {
        guard let onClose = self.onClose else {return}
        onClose()
    }
    
    // MARK: Setup
    public func setup(model: ScanResultModel, onClose: @escaping()->Void) {
        self.onClose = onClose
        self.model = model
    }
    
    private func setData() {
        guard let model = self.model else {return}
        nameLabel.text = model.name
        switch model.status {
        case .fully:
            statusContainer.backgroundColor = Constants.UI.Status.vaccinatedColor
        case .none:
            statusContainer.backgroundColor = Constants.UI.Status.notVaccinatedColor
        case .partially:
            statusContainer.backgroundColor = Constants.UI.Status.partiallyVaccinated
        }
    }
    
    private func style() {
        // Strings
        scanButton.setTitle(Constants.Strings.scanAgain, for: .normal)
        titleLabel.text = Constants.Strings.vaccinationStatusHeader
        
        // Colours
        view.backgroundColor = Constants.UI.Theme.primaryColor
        closeButton.tintColor = Constants.UI.Theme.primaryConstractColor
        titleLabel.textColor = Constants.UI.Theme.primaryConstractColor
        nameLabel.textColor = Constants.UI.Theme.primaryConstractColor
        divider.backgroundColor = Constants.UI.Theme.secondaryColor
        
        scanButton.backgroundColor = Constants.UI.Theme.primaryConstractColor
        scanButton.layer.borderWidth = 2
        scanButton.layer.borderColor = Constants.UI.Theme.primaryColor.cgColor
        scanButton.setTitleColor(Constants.UI.Theme.primaryColor, for: .normal)
        
        // Fonts
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        if let btnLabel = scanButton.titleLabel {
            btnLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }

}
