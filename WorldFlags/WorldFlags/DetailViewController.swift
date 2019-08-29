//
//  DetailViewController.swift
//  WorldFlags
//
//  Created by Liem Vo on 8/29/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView?
	var selectedName: String? = nil
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if let imageName = selectedName {
        	imageView?.image = UIImage(named: imageName)
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
    }
	
	@objc
	func shareImage() {
		guard let image = imageView?.image?.jpegData(compressionQuality: 0.8) else {
			return
		}
		
		let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true)
	}

}
