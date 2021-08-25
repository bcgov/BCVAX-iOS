//
//  ScanResultViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit

class ScanResultViewController: UIViewController {
    
    // MARK: Constants
    let cellNames: [String] = ["LabelTableViewCell", "VaccineQRCodeTableViewCell"]

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupTable()
        style()
    }
    
    func style() {
        tableView.backgroundColor = .clear
        view.backgroundColor = Constants.UI.Theme.primaryColor
    }

}

// MARK: TableView
extension ScanResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    private enum sections: Int, CaseIterable {
        case Name = 0
        case Age
        case QRCode
    }
    
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        for cell in cellNames {
            registerCell(name: cell)
        }
    }
    
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getLabelCell(indexPath: IndexPath) -> LabelTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell", for: indexPath) as! LabelTableViewCell
    }
    
    func getQRCodeCell(indexPath: IndexPath) -> VaccineQRCodeTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "VaccineQRCodeTableViewCell", for: indexPath) as! VaccineQRCodeTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = sections.init(rawValue: indexPath.row) else {return UITableViewCell()}
        switch section {
        case .Name:
            let cell = getLabelCell(indexPath: indexPath)
            cell.setup(header: "Name", value: "xyz")
            return cell
        case .Age:
            let cell = getLabelCell(indexPath: indexPath)
            cell.setup(header: "Date of Birth", value: "xyz")
            return cell
        case .QRCode:
            let cell = getQRCodeCell(indexPath: indexPath)
            cell.setup()
            return cell
        }
    }
    
    
}

