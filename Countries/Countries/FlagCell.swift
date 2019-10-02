//
//  FlagCell.swift
//  Countries
//
//  Created by Liem Vo on 10/2/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class FlagCell: UITableViewCell {

	@IBOutlet weak var flagImage: UIImageView!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
