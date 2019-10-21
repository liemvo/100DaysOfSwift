//
//  ViewController.swift
//  Project22
//
//  Created by Liem Vo on 10/21/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

	@IBOutlet weak var distanceReading: UILabel!
	var locationManager: CLLocationManager?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
		
		view.backgroundColor = .gray
	}


	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				if CLLocationManager.isRangingAvailable() {
					startScanning()
				}
			}
		}
	}
	
	func startScanning() {
		guard let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") else {
			return
		}
		let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "My Beacon")
		locationManager?.startMonitoring(for: beaconRegion)
		locationManager?.startRangingBeacons(in: beaconRegion)
	}
	
	func update(distance: CLProximity) {
		UIView.animate(withDuration: 1) {
			switch distance {
			case .unknown:
				self.view.backgroundColor = .gray
				self.distanceReading.text = "UNKNOWN"
			case .far:
				self.view.backgroundColor = .blue
				self.distanceReading.text = "FAR"
			case .near:
				self.view.backgroundColor = .orange
				self.distanceReading.text = "NEAR"
			case .immediate:
				self.view.backgroundColor = .red
				self.distanceReading.text = "RIGHT HERE"
			@unknown default:
				self.view.backgroundColor = .black
				self.distanceReading.text = "WHOA!"
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		if let beacon  = beacons.first {
			update(distance: beacon.proximity)
		} else {
			update(distance: .unknown)
		}
	}
}

