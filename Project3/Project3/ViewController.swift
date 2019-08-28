//
//  ViewController.swift
//  Project3
//
//  Created by Liem Vo on 8/28/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	private var images = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadImages()
		tableView.dataSource = self
		tableView.delegate = self
		title = "Storm Viewer"
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	private func loadImages() {
		let fm = FileManager.default
		let path = Bundle.main.resourcePath!
		let items = try! fm.contentsOfDirectory(atPath: path)
		for item in items {
			if item.hasPrefix("img") {
				images.append(item)
			}
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return images.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
		cell.textLabel?.text = "Image Name \(images[indexPath.row])"
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
			detailViewController.selectedData = SelectData(selectName: images[indexPath.row], position: indexPath.row + 1, count: images.count)
			navigationController?.pushViewController(detailViewController, animated: true)
		}
	}

}

