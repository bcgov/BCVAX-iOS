//
//  ScanResultViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit
import BCVaccineValidator

class ScanResultViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var scanButton: UIButton!
    
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
    
    private var timer: Timer?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
        case .pad:
            return [.portrait, .portraitUpsideDown, .landscape]
        case .phone:
            return .portrait
        case .tv:
            return .portrait
        default:
            return .portrait
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setData()
        setupAccessibilityTags()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setData()
        beginAutoDismissTimer()
    }
    
    // MARK: Outlet Actions
    @IBAction func scanButtonAction(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dimissPage()
    }
    
    private func dimissPage() {
        timer?.invalidate()
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
        nameLabel.text = model.name.uppercased()
        switch model.status {
        case .Fully:
            styleVaxinatedCard()
        case .None:
            styleNotVaxinatedCard()
        case .Partially:
            stylePartiallyVaxinatedCard()
        }
    }
    
    func beginAutoDismissTimer() {
        if let t = timer {
            t.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: Constants.dismissResultsAfterSeconds, repeats: false) {[weak self] timer in
            guard let `self` = self else {return}
            self.dimissPage()
        }
    }
    
    // MARK: Style
    private func style() {
        // Strings
        scanButton.setTitle(Constants.Strings.scanAgain, for: .normal)
        titleLabel.text = Constants.Strings.vaccinationStatusHeader
        
        // Colours
        view.backgroundColor = Constants.UI.Theme.primaryColor
        titleLabel.textColor = Constants.UI.Theme.primaryConstractColor
        nameLabel.textColor = Constants.UI.Theme.primaryConstractColor
        divider.backgroundColor = Constants.UI.Theme.secondaryColor
        
        scanButton.backgroundColor = Constants.UI.Theme.primaryConstractColor
        scanButton.layer.borderWidth = 2
        scanButton.layer.borderColor = Constants.UI.Theme.primaryColor.cgColor
        scanButton.setTitleColor(Constants.UI.Theme.primaryColor, for: .normal)
        
        // Fonts
        titleLabel.font = Constants.UI.ScanResult.titleFont
        
        let nameFont = Constants.UI.ScanResult.nameFont
        nameLabel.font = nameFont
        nameLabel.font = UIFontMetrics.default.scaledFont(for: nameFont)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.adjustsFontSizeToFitWidth = true
        
        if let btnLabel = scanButton.titleLabel {
            btnLabel.font = Constants.UI.ScanResult.buttonFont
        }
    }
    
    private func styleStatusCard() {
        cardTitle.font = Constants.UI.ScanResult.cardTitleFont
        cardTitle.numberOfLines = 0
        cardSubtitle.font = Constants.UI.ScanResult.cardSubtitleFont
        statusCardContainer.backgroundColor = .clear
        statusCardContainer.layer.borderColor = UIColor.white.cgColor
        statusCardContainer.layer.borderWidth = 6
        
        cardTitle.textColor = .white
        cardSubtitle.textColor = .white
    }
    
    private func styleVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.fullyVaccinated.color
        styleStatusCard()
        cardIcon.image = UIImage(named: "checkmark")
        cardTitle.text = Constants.UI.Status.fullyVaccinated.cardTitle.uppercased()
        cardSubtitle.text = Constants.UI.Status.fullyVaccinated.cardSubtitle
        cardTitle.textAlignment = .center
    }
    
    private func styleNotVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.notVaccinated.color
        styleStatusCard()
        cardIcon.isHidden = true
        let resultTitle = Constants.UI.Status.notVaccinated.cardTitle
        cardTitle.text = resultTitle.uppercased()
        cardTitle.accessibilityLabel = resultTitle
        cardSubtitle.text = Constants.UI.Status.notVaccinated.cardSubtitle
        cardTitle.textAlignment = .center
    }
    
    private func stylePartiallyVaxinatedCard() {
        statusContainer.backgroundColor = Constants.UI.Status.partiallyVaccinated.color
        styleStatusCard()
        cardIcon.isHidden = true
        let resultTitle = Constants.UI.Status.partiallyVaccinated.cardTitle
        cardTitle.text = resultTitle.uppercased()
        cardTitle.accessibilityLabel = resultTitle
        cardSubtitle.text = Constants.UI.Status.partiallyVaccinated.cardSubtitle
        cardTitle.textAlignment = .center
        statusCardContainer.layer.borderWidth = 0
        view.layoutIfNeeded()
        statusContainer.layoutIfNeeded()
        statusCardContainer.addDashedBorder(color: UIColor.white.cgColor, width: 6)
    }
    
    func setupAccessibilityTags() {
        view.accessibilityTraits = .allowsDirectInteraction
        view.accessibilityLabel = AccessibilityLabels.ScanResultView.view
        cardTitle.accessibilityTraits = .allowsDirectInteraction
        scanButton.accessibilityTraits = .allowsDirectInteraction
        nameLabel.accessibilityTraits = .allowsDirectInteraction
        
        titleLabel.accessibilityLabel = AccessibilityLabels.ScanResultView.titleLabel
        scanButton.accessibilityLabel = AccessibilityLabels.ScanResultView.scanButton
        
        cardIcon.isAccessibilityElement = false
        cardIcon.accessibilityTraits = .notEnabled
        
        logo.isAccessibilityElement = false
        logo.accessibilityTraits = .notEnabled
        
        divider.isAccessibilityElement = false
        divider.accessibilityTraits = .notEnabled
        
    }

}
