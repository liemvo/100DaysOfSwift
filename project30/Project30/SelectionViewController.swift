//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	
	var dirty = false
	private var documentUrl: URL!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Reactionist"
		
		tableView.rowHeight = 90
		tableView.separatorStyle = .none
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		
		// load all the JPEGs into our array
		let fm = FileManager.default
		documentUrl = getDocumentsDirectory()
		
		if let path = Bundle.main.resourcePath {
			if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
				for item in tempItems {
					if item.range(of: "Large") != nil {
						items.append(item)
					}
				}
			}
		}
		
		generateImages()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// Return the number of sections.
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return the number of rows in the section.
		return items.count * 10
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		let newName = currentImage.replacingOccurrences(of: "Large", with: "Generate")
		let image = UIImage(contentsOfFile: URL(fileURLWithPath: documentUrl.absoluteString).appendingPathComponent(newName).path)
		cell.imageView?.image = image
		
		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
		cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90))).cgPath
		
		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self
		
		// mark us as not needing a counter reload when we return
		dirty = false
		
		navigationController!.pushViewController(vc, animated: true)
	}
	
	
	private func createImage(name imageName: String) -> UIImage {
		let imageRootName = imageName.replacingOccurrences(of: "Large", with: "Thumb")
		let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
		let original = UIImage(contentsOfFile: path)!
		
		let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
		let renderer = UIGraphicsImageRenderer(size: renderRect.size)
		
		let rounded = renderer.image { ctx in
			ctx.cgContext.addEllipse(in: renderRect)
			ctx.cgContext.clip()
			
			original.draw(in: renderRect)
		}
		
		return rounded
	}
	
	private func generateImages() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			if let count = self?.items.count, let url = self?.documentUrl {
				for i in 0 ..< count {
					if let name = self?.items[i] {
						if let image = self?.createImage(name: name) {
							let newName = name.replacingOccurrences(of: "Large", with: "Generate")
							if let imageData = image.jpegData(compressionQuality: 80) {
								do {
									try imageData.write(to: url.appendingPathComponent(newName))
								} catch {
									print(error.localizedDescription)
								}
							}
						}
					}
				}
			}
		}
	}
	
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
