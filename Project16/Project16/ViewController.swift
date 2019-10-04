//
//  ViewController.swift
//  Project16
//
//  Created by Liem Vo on 10/3/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
	
	@IBOutlet weak var mapView: MKMapView!
	override func viewDidLoad() {
		super.viewDidLoad()
	
		mapView.delegate = self
		title = "Capital City"
		setupCapitals()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(chooseMapType))
	}
	
	@objc private func chooseMapType() {
		let ac = UIAlertController(title: "Map Type", message: "Please choose map type", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Satellite", style: .default) { [weak self] _ in
			self?.mapView.mapType = .satellite
		})
		ac.addAction(UIAlertAction(title: "Standard", style: .default){ [weak self] _ in
			self?.mapView.mapType = .standard
		})
		ac.addAction(UIAlertAction(title: "Hybrid", style: .default){ [weak self] _ in
			self?.mapView.mapType = .hybrid
		})
		present(ac, animated: true)
		
	}
	
	private func setupCapitals() {
		let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
		let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
		let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
		let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
		let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
		let wellington = Capital(title: "Wellington", coordinate: CLLocationCoordinate2D(latitude: -41.28664, longitude: 174.77557), info: "Smallest captital city")
		mapView.addAnnotation(london)
		mapView.addAnnotation(oslo)
		mapView.addAnnotation(paris)
		mapView.addAnnotation(rome)
		mapView.addAnnotation(washington)
		mapView.addAnnotation(wellington)
	}
	
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard annotation is Capital else { return nil }
		
		let identifier = "Capital"
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
		
		if annotationView == nil {
			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView?.canShowCallout = true
			
			let btn = UIButton(type: .detailDisclosure)
			annotationView?.rightCalloutAccessoryView = btn
		} else {
			annotationView?.annotation = annotation
		}
		annotationView?.pinTintColor = UIColor.blue
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let capital = view.annotation as? Capital else { return }

		if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
			detailViewController.capital = capital
			navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
}

