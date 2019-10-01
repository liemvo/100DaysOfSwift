//
//  ViewController.swift
//  Project13
//
//  Created by Liem Vo on 9/25/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var intensity: UISlider!
	@IBOutlet var radius: UISlider!
	var currentImage: UIImage!
	var currentSelectedTitle: String = "CISepiaTone"
	var context: CIContext!
	var currentFilter: CIFilter!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "YACIFP"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
		context = CIContext()
		currentFilter = CIFilter(name: currentSelectedTitle)
	}
	
	@IBAction func intensityChanged(_ sender: Any) {
		applyProcessing()
	}
	
	@IBAction func radiusChanged(_ sender: Any) {
		updateRadius()
	}
	
	@IBAction func changeFilter(_ sender: Any) {
		let ac = UIAlertController(title: currentSelectedTitle, message: nil, preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIBloom", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(ac, animated: true)
	}
	
	@IBAction func save(_ sender: Any) {
		guard let image = imageView.image else {
			showAlert(title: "No image!!!", message: "There is no image.")
			return
		}
		
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo
			:)), nil)
	}
	
	private func showAlert(title: String, message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default))
		present(ac, animated: true)
	}
	
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// we got back an error!
			let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		} else {
			let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
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
		
		updateFilter()
	}
	
	private func applyProcessing() {
		let inputKeys = currentFilter.inputKeys
		
		if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
		if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
		if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
		if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
		if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue( NSNumber(value: radius.value * 30), forKey: kCIInputRadiusKey) }
		
		if let currentImage = currentFilter.outputImage {
			if let cgimg = context.createCGImage(currentImage, from: currentImage.extent) {
				let processedImage = UIImage(cgImage: cgimg)
				
				UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
					self.imageView.alpha = 0.0
					self.imageView.image = processedImage
				}) { finished in
					self.imageView.alpha = 1.0
				}
				
			}
		}
	}
	
	func setFilter(action: UIAlertAction) {
		// safely read the alert action's title
		guard let actionTitle = action.title else { return }
		currentSelectedTitle = actionTitle
		
		// make sure we have a valid image before continuing!
		guard currentImage != nil else { return }
		
		currentFilter = CIFilter(name: currentSelectedTitle)
		
		updateFilter()
	}
	
	func updateRadius() {
		guard currentImage != nil else { return }
		currentFilter = CIFilter(name: currentSelectedTitle)
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		applyProcessing()
	}
	
	private func updateFilter() {
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		
		applyProcessing()
	}
}

