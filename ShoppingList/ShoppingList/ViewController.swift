//
//  ViewController.swift
//  ShoppingList
//
//  Created by Liem Vo on 9/6/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

	private var shoppingList = [String]()
	private var addButton: UIBarButtonItem? = nil
	private var shareButton: UIBarButtonItem? = nil
	override func viewDidLoad() {
		super.viewDidLoad()
		addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
		shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList))
		navigationItem.rightBarButtonItems = [addButton!, shareButton!]
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shoppingList.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
		cell.textLabel?.text = shoppingList[indexPath.row]
		return cell
	}
	
	@objc private func addItem() {
		let ac = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		let submitAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] action in
			guard let item = ac?.textFields?[0].text else { return }
			self?.addItemToList(item)
		}
		
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	private func addItemToList(_ item: String) {
		shoppingList.insert(item, at: 0)
		let indexPath = IndexPath(row: 0, section: 0)
		tableView.insertRows(at: [indexPath], with: .automatic)
	}
	
	@objc func shareList() {
		let activityViewController = UIActivityViewController(activityItems: [shoppingList.joined(separator: "\n")], applicationActivities: [])
		activityViewController.popoverPresentationController?.barButtonItem = shareButton
		present(activityViewController, animated: true)
	}
}

