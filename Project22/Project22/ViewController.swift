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
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var distanceReading: UILabel!
	@IBOutlet weak var secondDistanceReading: UILabel!
	var locationManager: CLLocationManager?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
		
		view.backgroundColor = .gray
		self.imageView.layer.cornerRadius = 128
		
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
	
	func update(distance: CLProximity, label: UILabel) {
		UIView.animate(withDuration: 1) {
			var scale: Float = 0.001
			switch distance {
			case .unknown:
				self.view.backgroundColor = .gray
				label.text = "UNKNOWN"
				scale = 0.001
			case .far:
				self.view.backgroundColor = .blue
				label.text = "FAR"
				scale = 0.25
			case .near:
				self.view.backgroundColor = .orange
				label.text = "NEAR"
				scale = 0.5
			case .immediate:
				self.view.backgroundColor = .red
				label.text = "RIGHT HERE"
				scale = 1.0
			@unknown default:
				self.view.backgroundColor = .black
				label.text = "WHOA!"
			}
			label.isHidden = true
			UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
				self.imageView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
			}) { _ in
				label.isHidden = false
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		if let beacon = beacons.first{
			update(distance: beacon.proximity, label: self.distanceReading)
			if beacons.count >= 2 {
				if let beacon2 = beacons[1] as? CLBeacon {
					update(distance: beacon2.proximity, label: self.secondDistanceReading)
				} else {
					update(distance: .unknown, label: secondDistanceReading)
				}
			} else {
				update(distance: .unknown, label: secondDistanceReading)
			}
			
			showFirstBeacons()
		} else {
			update(distance: .unknown, label: secondDistanceReading)
			update(distance: .unknown, label: distanceReading)
			
		}
	}
	
	private func showFirstBeacons() {
		let userDefault = UserDefaults.standard
		let isFirsBeatcon = userDefault.bool(forKey: "isFirsBeatcon")
		
		if (!isFirsBeatcon) {
			let ac = UIAlertController(title: "First beacon is appear", message: nil, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) in
				userDefault.set(true, forKey: "isFirsBeatcon")
			}))
			present(ac, animated: true)
		}
		
	}
}
