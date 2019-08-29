//
//  FlagsTabbleViewController.swift
//  WorldFlags
//
//  Created by Liem Vo on 8/29/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class FlagsTabbleViewController: UITableViewController {

	private var images = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadImages()
		title = "World Flags"
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return images.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
		cell.imageView?.image = UIImage(named: images[indexPath.row])
		cell.textLabel?.text = images[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
			detailViewController.selectedName = images[indexPath.row]
			navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
	
	private func loadImages() {
		let fm = FileManager.default
		let path = Bundle.main.resourcePath!
		let items = try! fm.contentsOfDirectory(atPath: path)
		for item in items {
			if item.hasPrefix("flag"){
				images.append(item)
			}
		}
	}
}

