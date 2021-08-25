//
//  UIView.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation
import UIKit

extension UIView {
    func startLoadingIndicator() {
        if let existing = self.viewWithTag(Constants.UI.LoadingIndicator.backdropTag) {
            existing.removeFromSuperview()
        }
        
        let backdrop = UIView(frame: .zero)
        backdrop.tag = Constants.UI.LoadingIndicator.backdropTag
        let indicator = UIActivityIndicatorView(frame: .zero)
        let loadingContainer = UIView(frame:.zero)
        
        self.addSubview(backdrop)
        backdrop.addSubview(loadingContainer)
        loadingContainer.addSubview(indicator)
        
        backdrop.backgroundColor = Constants.UI.LoadingIndicator.backdropColor
        loadingContainer.backgroundColor = Constants.UI.LoadingIndicator.containerColor
        loadingContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
        backdrop.addEqualSizeContraints(to: self)
        
        loadingContainer.center(in: backdrop, width: Constants.UI.LoadingIndicator.containerSize, height: Constants.UI.LoadingIndicator.containerSize)
        indicator.center(in: loadingContainer, width: Constants.UI.LoadingIndicator.size, height: Constants.UI.LoadingIndicator.size)
        
        indicator.startAnimating()
    }
    
    func endLoadingIndicator() {
        if let existing = self.viewWithTag(Constants.UI.LoadingIndicator.backdropTag) {
            existing.removeFromSuperview()
        }
    }
    
    public func addEqualSizeContraints(to toView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: toView.heightAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalTo: toView.widthAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0).isActive = true
    }
    
    public func center(in view: UIView, width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
}
