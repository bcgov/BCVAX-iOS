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
    @IBOutlet weak var statusCardContainer: UIView!
    
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardSubtitle: UILabel!
    
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
            styleVaxinatedCard()
        case .none:
            styleNotVaxinatedCard()
        case .partially:
            stylePartiallyVaxinatedCard()
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
    
    private func styleStatusCard() {
        cardTitle.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        cardTitle.numberOfLines = 0
        cardSubtitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        statusCardContainer.backgroundColor = .clear
        statusCardContainer.layer.borderColor = UIColor.white.cgColor
        statusCardContainer.layer.borderWidth = 6
    }
    
    private func styleVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.fullyVaccinated.color
        styleStatusCard()
        cardIcon.image = UIImage(named: "checkmark")
        cardTitle.text = Constants.UI.Status.fullyVaccinated.cardTitle
        cardSubtitle.text = Constants.UI.Status.fullyVaccinated.cardSubtitle
    }
    
    private func styleNotVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.notVaccinated.color
        styleStatusCard()
        cardIcon.isHidden = true
        cardTitle.text = Constants.UI.Status.notVaccinated.cardTitle
        cardSubtitle.text = Constants.UI.Status.notVaccinated.cardSubtitle
    }
    
    private func stylePartiallyVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.partiallyVaccinated.color
        styleStatusCard()
        cardIcon.isHidden = true
        cardTitle.text = Constants.UI.Status.partiallyVaccinated.cardTitle
        cardSubtitle.text = Constants.UI.Status.partiallyVaccinated.cardSubtitle
        statusCardContainer.layer.borderWidth = 0
        statusCardContainer.addDashedBorder(color: UIColor.white.cgColor, width: 6)
    }

}
