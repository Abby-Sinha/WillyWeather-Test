//
//  DetailsTableViewCell.swift
//  WillyWeatherTest
//
//  Created by Abhishek Sinha on 25/11/20.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var btnDownloadORCancel: UIButton!
    @IBOutlet var lblDetails: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
