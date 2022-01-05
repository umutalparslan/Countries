//
//  SavedCountriesCell.swift
//  Countries
//
//  Created by Umut Can Alparslan on 5.01.2022.
//

import UIKit

class SavedCountriesCell: UITableViewCell {

    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var actionBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        actionBlock?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
