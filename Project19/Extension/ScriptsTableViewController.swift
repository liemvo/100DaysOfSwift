//
//  ScriptsTableViewController.swift
//  Extension
//
//  Created by Liem Vo on 10/13/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ScriptsTableViewController: UITableViewController {

	private var scripts: [URL]? = nil
	var repository: RepositoryProtocol = Repository()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		scripts = repository.loadScripts()
    }
	
	private func loadSaveScript() {
		let defaults = UserDefaults.standard
		
		if let savedScripts = defaults.object(forKey: "scripts") as? Data {
			let jsonDecoder = JSONDecoder()
			
			do {
				scripts = try jsonDecoder.decode([URL].self, from: savedScripts)
			} catch {
				print("Failed to load scripts")
			}
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return scripts?.count ?? 0
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "scriptCell", for: indexPath)
		cell.textLabel?.text = scripts![indexPath.row].title
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let ac = UIAlertController(title: "Option", message: nil, preferredStyle: .alert)
		let url = scripts![indexPath.row]
		ac.addAction(UIAlertAction(title: "Edit name", style: .default, handler: { [weak self] _ in
			self?.editTitle(url)
		}))
		ac.addAction(UIAlertAction(title: "Load", style: .default, handler:{ [weak self] _ in
			self?.repository.saveLoad(url.url)
		}))
		present(ac, animated: true)
	}
	
	func editTitle(_ url: URL) {
		let ac = UIAlertController(title: "Edit name", message: nil, preferredStyle: .alert)
		ac.addTextField()
		ac.textFields?.first?.text = url.title
		
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
			guard let newTitle = ac?.textFields?[0].text else { return }
			url.title = newTitle
			
			self?.tableView.reloadData()
			self?.repository.saveScripts(self?.scripts)
		})
		
		present(ac, animated: true)
	}
}
