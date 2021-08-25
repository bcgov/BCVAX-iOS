//
//  LabelTableViewCell.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(header: String, value: String) {
        self.headerLabel.text = header
        self.valueLabel.text = value
        style()
    }
    
    func style() {
        labelContainer.backgroundColor = Constants.UI.Field.textBackground
        labelContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        valueLabel.textColor = Constants.UI.Field.textColor
        valueLabel.font = Constants.UI.Field.font
        headerLabel.textColor = Constants.UI.Field.headerColor
        headerLabel.font = Constants.UI.Field.headerFont
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
