//
//  ViewController.swift
//  Project13
//
//  Created by Liem Vo on 9/25/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var intensity: UISlider!
	var currentImage: UIImage!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "YACIFP"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
	}

	@IBAction func intensityChanged(_ sender: Any) {
	}
	@IBAction func changeFilter(_ sender: Any) {
	}
	@IBAction func save(_ sender: Any) {
	}
	
	@objc private func importPicture() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }

		dismiss(animated: true)

		currentImage = image
		imageView.image = currentImage
	}
}

