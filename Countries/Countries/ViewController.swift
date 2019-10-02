//
//  ViewController.swift
//  Countries
//
//  Created by Liem Vo on 10/2/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

	var countries = [Country]()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		performSelector(inBackground: #selector(loadData), with: nil)
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return countries.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath)
		let country = countries[indexPath.row]
		cell.imageView?.image = UIImage(named: "\(country.flagCode).png")
		cell.textLabel?.text = country.name
		cell.detailTextLabel?.text = country.capital
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailViewController {
			detailViewController.country = countries[indexPath.row]
            navigationController?.pushViewController(detailViewController, animated: true)
        }
	}
	
	@objc private func loadData() {
		if let jsonURL = Bundle.main.url(forResource: "countries", withExtension: "json") {
			if let data = try? Data(contentsOf: jsonURL) {
				parse(json: data)
				return
			}
		}
	}
	
	private func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let jsonCountries = try? decoder.decode([Country].self, from: json) {
			countries = jsonCountries
			tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
		} else {
			performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
		}
	}
	
	@objc private func showError() {
		let ac = UIAlertController(title: "Loading error", message: "There was a problem loading data.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
}

