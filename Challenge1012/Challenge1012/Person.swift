//
//  Person.swift
//  Challenge1012
//
//  Created by Liem Vo on 9/23/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import Foundation

class Person: NSObject, Codable {
	var name: String
	var image: String
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
