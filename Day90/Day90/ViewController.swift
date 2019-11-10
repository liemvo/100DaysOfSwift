//
//  ViewController.swift
//  Day90
//
//  Created by Liem Vo on 11/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
	
	@IBOutlet weak var imageView: UIImageView!
	
	private var selectedImage: UIImage? {
		didSet {
			shareButton?.isEnabled = selectedImage != nil
		}
	}
	private var topText: String?
	private var bottomText: String?
	
	private var shareButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
		shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
		navigationItem.rightBarButtonItem = shareButton
	}
	
	@IBAction func importPicture(_ sender: Any) {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	
	@IBAction func setTopText(_ sender: Any) {
		presentAddTextAlert(title: "Add top text") { [weak self] text in
			self?.topText = text
			self?.imageView.image = self?.createImage(self?.selectedImage)
		}
	}
	
	@IBAction func setBottomText(_ sender: Any) {
		self.presentAddTextAlert(title: "Add bottom text") { [weak self] text in
			self?.bottomText = text
			self?.imageView.image = self?.createImage(self?.selectedImage)
		}
	}
	
	private func presentAddTextAlert(title: String, callback: @escaping (String) ->(Void)) {
		let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		ac.addTextField()
		ac.addAction(UIAlertAction(title: "Ok", style: .default){[weak ac]_ in
			guard let text = ac?.textFields?[0].text else { return }
			callback(text)
		})
		present(ac, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image  = info[.editedImage] as? UIImage else { return }
		dismiss(animated: true)
		self.selectedImage = image
		self.imageView.image = self.createImage(self.selectedImage)
	}
	
	@objc func shareTapped() {
		guard let image = imageView.image?.jpegData(compressionQuality: 80) else {
			
			return
		}
		
		let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true)
	}
	
	private func showMissingAlert() {
		let ac = UIAlertController(title: "Error!!!", message: "Missing image", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default))
		present(ac, animated: true)
	}
	
	private func createImage(_ originalImage: UIImage?) -> UIImage? {
		guard let originalImage = originalImage else {
			self.showMissingAlert()
			return nil
		}
		let size = originalImage.size
		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image { [weak self] context in
			originalImage.draw(at: CGPoint(x: 0, y: 0))
			
			if let topText = self?.topText {
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.alignment = .left
				
				if let attributedString = self?.createAttribute(topText, paragraphStyle: paragraphStyle) {
					
					attributedString.draw(with: CGRect(x: 5, y: 5, width: size.width, height: 100), options: .usesLineFragmentOrigin, context: nil)
				}
			}
			
			if let bottomText = self?.bottomText {
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.alignment = .right
				
				if let attributedString = self?.createAttribute(bottomText, paragraphStyle: paragraphStyle) {
					
					attributedString.draw(with: CGRect(x: 0, y: size.height - 100, width: size.width - 10, height: 100), options: .usesLineFragmentOrigin, context: nil)
				}
			}
		}
		return image
	}
	
	private func createAttribute(_ text: String, paragraphStyle: NSParagraphStyle) -> NSAttributedString {
		let attrs: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 48),
			.foregroundColor: UIColor.white,
			.paragraphStyle: paragraphStyle
		]
		
		return NSAttributedString(string: text, attributes: attrs)
	}
}

