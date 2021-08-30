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
    
    func showBanner(message: String) {
        // padding Constants
        let textPadding: CGFloat = Constants.UI.Banner.labelPadding
        let containerPadding: CGFloat = Constants.UI.Banner.containerPadding
        
        // Create label and container
        let container = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        
        container.alpha = 0 // So we can animate the displaying
        
        // Remove existing Banner / Container
        if let existing = view.viewWithTag(Constants.UI.Banner.tag) {
            existing.removeFromSuperview()
        }
        
        // Add subviews
        container.tag = Constants.UI.Banner.tag
        let labelTAG = Int.random(in: 4000..<9000)
        label.tag = labelTAG
        self.view.addSubview(container)
        container.addSubview(label)
        
        // Position container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0 - containerPadding).isActive = true
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: containerPadding).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0 - containerPadding).isActive = true
        let messageHeight = message.heightForView(font: Constants.UI.Banner.labelFont, width: container.bounds.width)
        container.heightAnchor.constraint(equalToConstant: messageHeight + (textPadding * 2)).isActive = true
        
        // Position Label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0 - textPadding).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: textPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0 - textPadding).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: textPadding).isActive = true
        
        // Style
        label.text = message
        label.textAlignment = .center
        label.font = Constants.UI.Banner.labelFont
        label.textColor = Constants.UI.Banner.labelColor
        container.backgroundColor = Constants.UI.Banner.backgroundColor
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
        // Animate the displaying of banner (just fades in)
        UIView.animate(withDuration: Constants.UI.Theme.animationDuration) {
            container.alpha = 1
        }
        
        // Remove banner after x seconds
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.UI.Banner.displayDuration) {[weak self] in
            guard let `self` = self,
                  let container = self.view.viewWithTag(Constants.UI.Banner.tag),
                  let label = container.viewWithTag(labelTAG)
                  else {return}
            /*
             We Randomly generated labelTAG.
             here we check if after the display duration, the same label is still displayed.
             this helps us avoid removing a banner that was just displayed
             */
            container.removeFromSuperview()
        }
    }
    
    func hideBanner() {
        guard let banner = view.viewWithTag(Constants.UI.Banner.tag) else {
            return
        }
        UIView.animate(withDuration: Constants.UI.Theme.animationDuration) {
            banner.alpha = 0
        } completion: { done in
            banner.removeFromSuperview()
        }

    }
}
