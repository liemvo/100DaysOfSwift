//
//  Person.swift
//  Project12a
//
//  Created by Liem Vo on 9/17/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class Person: NSObject, NSCoding {
	func encode(with coder: NSCoder) {
		coder.encode(name, forKey: "name")
		coder.encode(image, forKey: "image")
	}
	
	required init(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
		image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
	}
	
	var name: String
	var image: String
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
