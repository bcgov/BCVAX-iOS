//
//  VaccineQRCodeTableViewCell.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit

class VaccineQRCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var colorContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        colorContainer.backgroundColor = Constants.UI.Status.vaccinatedColor
        statusLabel.text = "Vaccinated"
        style()
    }
    
    func style() {
        backgroundColor = .clear
        statusLabel.textColor = Constants.UI.Status.textColor
        statusLabel.font = Constants.UI.Status.font
    }
    
}
