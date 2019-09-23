//
//  DetailsViewController.swift
//  Challenge1012
//
//  Created by Liem Vo on 9/23/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
	var person: Person?
	@IBOutlet weak var imageView: UIImageView!
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if let person = person {
			let path = getDocumentsDirectory().appendingPathComponent(person.image)
			imageView.image = UIImage(contentsOfFile: path.path)
			
			imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
			imageView.layer.borderWidth = 2
			imageView.layer.cornerRadius = 3
			
			title = person.name
		}
    }

	
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
}
