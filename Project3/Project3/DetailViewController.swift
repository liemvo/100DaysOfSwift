//
//  DetailsViewController.swift
//  Project3
//
//  Created by Liem Vo on 8/28/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	var selectedData: SelectData?
	@IBOutlet weak var imageView: UIImageView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let data = selectedData {
			imageView?.image = UIImage(named: data.selectName)
			title = "\(data.position) of \(data.count)"
		}
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.hidesBarsOnTap = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.hidesBarsOnTap = false
	}

	@objc func shareTapped() {
		guard let image = imageView.image else {
			print("No image found")
			return
		}
		
		guard let imageData = self.createImage(image).jpegData(compressionQuality: 0.8) else {
			return
		}
		
		let vc = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true)
	}
	
	private func createImage(_ originalImage: UIImage) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: originalImage.size)
		let image = renderer.image { context in
			originalImage.draw(at: CGPoint(x: 0, y: 0))
			
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .left
			
			let attrs: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 36),
				.paragraphStyle: paragraphStyle
			]
			let string = "From Storm Viewer"
			
			let attributedString = NSAttributedString(string: string, attributes: attrs)
			
			attributedString.draw(with: CGRect(x: 0, y: 0, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
		}
		
		return image
	}
}
