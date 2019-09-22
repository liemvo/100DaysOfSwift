//
//  ViewController.swift
//  Project2
//
//  Created by Liem Vo on 8/26/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
	
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
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
	}
	
	private func setupButtons() {
		buttons.forEach {
			$0?.layer.borderWidth = 1
			$0?.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
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
}

