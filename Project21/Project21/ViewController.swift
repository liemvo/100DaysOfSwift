//
//  ViewController.swift
//  Project21
//
//  Created by Liem Vo on 10/17/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
	}

	
	@objc private func registerLocal() {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
			if granted {
				print("Yay!")
			} else {
				print("D'oh!")
			}
		}
	}
	
	@objc private func scheduleLocal() {
		let center = UNUserNotificationCenter.current()
		center.removeAllPendingNotificationRequests()
		
		let content = UNMutableNotificationContent()
		
		content.title = "Late wake up call"
		content.body = "The early bird catches the worm, but the second mouse gets the cheese."
		
		content.categoryIdentifier = "alarm"
		content.userInfo = ["customData" : "fizzbuzz"]
		content.sound = .default
		
		var dateComponents = DateComponents()
		dateComponents.hour = 10
		dateComponents.minute = 30
//		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
		
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		center.add(request)
	}
	
	private func registerCategories() {
		let center = UNUserNotificationCenter.current()
		
		center.delegate = self
		
		let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
		let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
		center.setNotificationCategories([category])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		if let customData = userInfo["customData"] as? String {
			print("Custom data received: \(customData)")
			
			switch response.actionIdentifier {
			case UNNotificationDefaultActionIdentifier:
				print("Default identifier")
			case "show":
				print("show more information...")
			default:
				break
			}
		}
		
		completionHandler()
	}
}

