//
//  SitesTableViewController.swift
//  Project4
//
//  Created by Liem Vo on 8/31/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class SitesTableViewController: UITableViewController {
	
	var websites = ["apple.com", "hackingwithswift.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Websites"
    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return websites.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = websites[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let browserController = storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
		browserController.selectPage = websites[indexPath.row]
		navigationController?.show(browserController, sender: self)
		
	}
}
