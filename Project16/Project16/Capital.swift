//
//  Capital.swift
//  Project16
//
//  Created by Liem Vo on 10/3/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
	var title: String?
	var coordinate: CLLocationCoordinate2D
	var info: String

	init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
