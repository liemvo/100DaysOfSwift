//
//  ImageCell.swift
//  Project1
//
//  Created by Liem Vo on 8/24/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var imageCell: UIImageView?
    
    func setView(file: String) {
        imageCell?.image = UIImage(named: file)
    }
    
}
