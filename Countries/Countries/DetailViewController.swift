//
//  DetailViewController.swift
//  Countries
//
//  Created by Liem Vo on 10/2/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
	
	var country: Country?
	override func viewDidLoad() {
		super.viewDidLoad()
		title = country?.name
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	@objc func shareTapped() {
		guard let selectCountry = country else {
			return
		}
		guard let image = UIImage(named: "\(selectCountry.flagCode).png")?.pngData() else {
			print("No image found")
			return
		}
		
		let vc = UIActivityViewController(activityItems: [image, selectCountry.name, selectCountry.capital, selectCountry.area], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 240.0
		} else {
			return 44.0
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "flag", for: indexPath)
			
			(cell as! FlagCell).flagImage.image = UIImage(named: "\(country!.flagCode).png")
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath)
			
			switch indexPath.row {
			case 1:
				cell.textLabel?.text = "Name: "
				cell.detailTextLabel?.text = country?.name
			case 2:
				cell.textLabel?.text = "Capital: "
				cell.detailTextLabel?.text = country?.capital
			case 3:
				cell.textLabel?.text = "Population: "
				cell.detailTextLabel?.text = country?.population
			case 4:
				cell.textLabel?.text = "Area: "
				cell.detailTextLabel?.text = country?.area
			default:
				cell.textLabel?.text = "Unknown"
			}
			
			return cell
		}
	}
}
