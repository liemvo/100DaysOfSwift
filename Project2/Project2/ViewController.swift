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
	
	private var correctAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
		buttons += [button1, button2, button3]
		setupButtons()
		askQuestion()
    }
	
	private func setupButtons() {
		buttons.forEach {
			$0?.layer.borderWidth = 1
			$0?.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
		}
	}

	private func askQuestion(action: UIAlertAction! = nil) {
		correctAnswer = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
		countries = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: countries) as! [String]
		for (index, button) in [button1, button2, button3].enumerated() {
			button?.setImage(UIImage(named: countries[index]), for: .normal)
		}
		title = countries[correctAnswer].uppercased()
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
		showResult(title: title)
	}
	
	private func showResult(title: String) {
		let alertViewController = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
		alertViewController.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
		present(alertViewController, animated: true)
	}
}

