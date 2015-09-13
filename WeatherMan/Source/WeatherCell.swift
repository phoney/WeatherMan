//
//  WeatherCell.swift
//  WeatherMan
//
//  Created by Brian Stern on 9/12/15.
//  Copyright © 2015 Brian Stern. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var forecastLabel: UILabel!
	@IBOutlet weak var highTempLabel: UILabel!
	@IBOutlet weak var lowTempLabel: UILabel!


	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
