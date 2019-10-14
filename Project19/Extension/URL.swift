//
//  URL.swift
//  Extension
//
//  Created by Liem Vo on 10/14/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class URL: NSObject, Codable {
	var url: String
	var title: String
	var script: String
	
	init(title: String, url: String, script: String) {
		self.title = title
		self.url = url
		self.script = script
	}
	
	func updateScript(_ script: String) -> URL{
		self.script = script
		return self
	}
}
