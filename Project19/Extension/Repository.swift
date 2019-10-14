//
//  Repository.swift
//  Extension
//
//  Created by Liem Vo on 10/14/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import Foundation

protocol RepositoryProtocol {
	func loadScripts() -> [URL]?
	func saveScripts(_ scripts: [URL]?)
	func saveLoad(_ url: String)
	func loadSaveURL() -> String?
	func clearLoad()
}

class Repository: RepositoryProtocol {
	
	func loadScripts() -> [URL]? {
		let defaults = UserDefaults.standard
		
		if let savedScripts = defaults.object(forKey: "scripts") as? Data {
			let jsonDecoder = JSONDecoder()
			
			do {
				let scripts = try jsonDecoder.decode([URL].self, from: savedScripts)
				return scripts
			} catch {
				print("Failed to load scripts")
				return nil
			}
		}
		
		return nil
	}
	
	func saveScripts(_ scripts: [URL]?) {
		if let saveScripts = scripts {
			let jsonEncoder = JSONEncoder()
			if let savedData = try? jsonEncoder.encode(saveScripts) {
				let defaults = UserDefaults.standard
				defaults.set(savedData, forKey: "scripts")
			} else {
				print("failed to save people")
			}
		}
	}
	
	func clearLoad() {
		let defaults = UserDefaults.standard
		defaults.set(nil, forKey: "saveUrl")
	}
	
	func saveLoad(_ url: String) {
		let defaults = UserDefaults.standard
		defaults.set(url, forKey: "savedUrl")
	}
	
	func loadSaveURL() -> String? {
		let defaults = UserDefaults.standard
		return defaults.value(forKey: "savedUrl") as? String
	}
}
