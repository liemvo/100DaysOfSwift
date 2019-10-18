//
//  ViewController.swift
//  Project2
//
//  Created by Liem Vo on 8/26/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
	
	@IBOutlet weak var button1: UIButton?
	@IBOutlet weak var button2: UIButton?
	@IBOutlet weak var button3: UIButton?
	
	private var buttons = [UIButton?]()
	
	private var countries = [String]()
	private var score = 0
	private var currentQuention = 0
	
	private var correctAnswer = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
		buttons += [button1, button2, button3]
		setupButtons()
		askQuestion()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
	}
	
	private func setupButtons() {
		buttons.forEach {
			$0?.layer.borderWidth = 1
			$0?.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
		}
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
	
	private func askQuestion(action: UIAlertAction! = nil) {
		if (currentQuention < 10) {
			correctAnswer = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
			countries = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: countries) as! [String]
			for (index, button) in [button1, button2, button3].enumerated() {
				button?.setImage(UIImage(named: countries[index]), for: .normal)
			}
			showTitle()
			currentQuention += 1
		} else {
			let userdefaults = UserDefaults.standard
			let savedScore = userdefaults.value(forKey: "score") as? Int ?? 0
			var message = "Your score is \(score)"
			if score > savedScore {
				userdefaults.set(score, forKey: "score")
				message = "\(message). You just beat your last score!"
			}
			
			let alertViewController = UIAlertController(title: "Congratulation!!!", message: message, preferredStyle: .alert)
			alertViewController.addAction(UIAlertAction(title: "Continue", style: .default, handler: reset))
			present(alertViewController, animated: true)
		}
	}
	
	private func reset(action: UIAlertAction! = nil) {
		score = 0
		currentQuention = 0
		correctAnswer = 0
	}
	
	
	@IBAction func buttonTapped(_ sender: UIButton) {
		var title: String
		if (sender.tag == correctAnswer) {
			score += 1
			title = "Correct"
		} else {
			score -= 1
			title = "Wrong"
		}
		UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
			sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}) { isFinished in
			sender.transform = .identity
		}
		showTitle()
		showResult(title: title)
	}
	
	private func showTitle() {
		title = "Flag: \(countries[correctAnswer].uppercased()), Score: \(score)"
	}
	
	private func getMessage(title: String) -> String {
		var message = "Your score is \(score)."
		if (currentQuention < 10) {
			if (title == "Wrong") {
				message = "Wrong! That's the flag of \(countries[correctAnswer])"
			}
		} else {
			message = "Your final score is \(score)"
		}
		return message
	}
	
	private func showResult(title: String) {
		
		let alertViewController = UIAlertController(title: title, message: getMessage(title: title), preferredStyle: .alert)
		alertViewController.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
		present(alertViewController, animated: true)
	}
	
	@objc
	private func showScore() {
		let alertViewController = UIAlertController(title: "Your score!!", message: "\(score)", preferredStyle: .alert)
		alertViewController.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
		present(alertViewController, animated: true)
	}
	
	@objc private func scheduleLocal() {
		let center = UNUserNotificationCenter.current()
		center.removeAllPendingNotificationRequests()
		
		let content = UNMutableNotificationContent()
		
		content.title = "Go back and play game"
		content.body = "This game is so cool you, please play every day!"
		
		content.categoryIdentifier = "alarm"
		content.userInfo = ["customData" : "fizzbuzz"]
		content.sound = .default
		
		var dateComponents = DateComponents()
		dateComponents.hour = 18
		dateComponents.minute = 30
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		
		
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
}

