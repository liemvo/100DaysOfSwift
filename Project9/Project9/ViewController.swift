//
//  ViewController.swift
//  Project9
//
//  Created by Liem Vo on 9/13/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	
	var petitions = [Petition]()
	var originals = [Petition]()

	override func viewDidLoad() {
		super.viewDidLoad()
		performSelector(inBackground: #selector(fetchData), with: nil)
		navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredit)),
		UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filter))]
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return petitions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let petition = petitions[indexPath.row]
		cell.textLabel?.text = petition.title
		cell.detailTextLabel?.text = petition.body
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = DetailViewController()
		vc.detailItem = petitions[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func fetchData() {
		let urlString: String
		if navigationController?.tabBarItem.tag == 0 {
			// urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
			urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
		} else {
			// urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
			urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
		}
		
		if let url = URL(string: urlString) {
			if let data = try? Data(contentsOf: url) {
				parse(json: data)
				return
			}
		}
		
		performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)

	}
	
	private func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
			petitions = jsonPetitions.results
			originals = petitions
			tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
		} else {
			performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
		}
	}
	
	@objc private func showError() {
		let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
	
	@objc private func showCredit() {
		let ac = UIAlertController(title: "Credit", message: "The data comes from the We the People API of the Whitehouse", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default))
		present(ac, animated: true)
	}
	
	@objc private func filter() {
		let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		let submitAction = UIAlertAction(title: "Filter", style: .default, handler:{ [weak self, weak ac] action in
			guard let item = ac?.textFields?[0].text else { return }
			self?.filterText(item)
		})
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	private func filterText(_ text: String) {
		petitions = petitions.filter({ (petition) -> Bool in
			petition.title.contains(text)
		})
		tableView.reloadData()
	}
}

