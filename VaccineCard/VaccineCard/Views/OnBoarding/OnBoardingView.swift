//
//  OnBoarding.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-09-16.
//

import UIKit

class OnBoardingView: UIView {
    
    var buttonCallback: (()->Void)?

    // MARK: Outlets
    @IBOutlet weak var onBoardTitle: UILabel!
    @IBOutlet weak var onBoardSubtitle: UILabel!
    @IBOutlet weak var onBoardContainer: UIView!
    @IBOutlet weak var onBoardButton: UIButton!
    @IBOutlet weak var onBoardImage: UIStackView!
    
    func setup(in container: UIView, onButtonTap: @escaping()->Void) {
        if let existing = container.viewWithTag(Constants.UI.onBoarding.tag) {
            existing.removeFromSuperview()
        }
        self.frame = .zero
        self.alpha = 0
        container.addSubview(self)
        self.tag = Constants.UI.onBoarding.tag
        self.addEqualSizeContraints(to: container)
        self.buttonCallback = onButtonTap
        style()
        setupAccessibilityTags()
        container.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 1, options: .curveEaseIn) {[weak self] in
            guard let `self` = self else {return}
            self.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func ButtonTapped(_ sender: Any) {
        guard let callback = buttonCallback else {return}
        callback()
    }
    
    func setupAccessibilityTags() {
        onBoardContainer.accessibilityLabel = AccessibilityLabels.OnBoarding.onboardingView
        onBoardButton.accessibilityLabel = AccessibilityLabels.OnBoarding.startScanningButton
        onBoardTitle.accessibilityLabel = AccessibilityLabels.OnBoarding.title
        onBoardSubtitle.accessibilityLabel = AccessibilityLabels.OnBoarding.subtitle
        onBoardImage.accessibilityLabel = AccessibilityLabels.OnBoarding.phoneImage
    }
    
    func style() {
        onBoardTitle.text = Constants.UI.onBoarding.title
        onBoardTitle.font = Constants.UI.onBoarding.titleFont
        onBoardSubtitle.text = Constants.UI.onBoarding.subtitle
        onBoardSubtitle.font = Constants.UI.onBoarding.subtitleFont
        onBoardButton.setTitle(Constants.UI.onBoarding.buttonTitle, for: .normal)
        onBoardButton.backgroundColor = Constants.UI.Theme.primaryColor
        onBoardButton.setTitleColor(Constants.UI.Theme.primaryConstractColor, for: .normal)
        onBoardButton.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        if let titleLabel = onBoardButton.titleLabel {
            titleLabel.font = Constants.UI.onBoarding.buttonFont
        }
        
        
    }
    
}
