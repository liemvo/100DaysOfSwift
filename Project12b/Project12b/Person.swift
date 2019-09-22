//
//  Person.swift
//  Project12b
//
//  Created by Liem Vo on 9/17/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//
import UIKit

class Person: NSObject, Codable {
	var name: String
	var image: String
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
