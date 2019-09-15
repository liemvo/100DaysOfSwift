//
//  ViewController.swift
//  Hangman
//
//  Created by Liem Vo on 9/15/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var scoreLabel: UILabel!
	var lifeLabel: UILabel!
	var answerLabel: UILabel!
	var letterButtons = [UIButton]()
	var level = 0
	
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	var life = 7 {
		didSet {
			lifeLabel.text = "Your life: \(life)"
		}
	}
	let words = ["HAUNTED", "LETPROSY", "TWITTER", "OLIVER", "ELIZABETH", "SAFARI", "PORTLAND"]
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
		
		scoreLabel = UILabel()
		scoreLabel.translatesAutoresizingMaskIntoConstraints = false
		scoreLabel.textAlignment = .right
		scoreLabel.text = "Score: 0"
		view.addSubview(scoreLabel)
		
		lifeLabel = UILabel()
		lifeLabel.translatesAutoresizingMaskIntoConstraints = false
		lifeLabel.textAlignment = .center
		lifeLabel.text = "Your life: 7"
		view.addSubview(lifeLabel)
		
		answerLabel = UILabel()
		answerLabel.translatesAutoresizingMaskIntoConstraints = false
		answerLabel.textAlignment = .center
		answerLabel.font = UIFont.systemFont(ofSize: 24)
		answerLabel.text = "ANSWERS"
		answerLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
		answerLabel.textAlignment = .right
		answerLabel.numberOfLines = 1
		view.addSubview(answerLabel)
		
		let buttonsView = UIView()
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonsView)
		let width = 40
		let height = 50
		for (index, char) in "abcdefghijklmnopqrstuvwxyz".enumerated() {
			let letterButton = UIButton(type: .system)
			letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
			letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
			let frame = CGRect(x: Int(index%9) * width, y: Int(index/9) * height, width: width, height: height)
			letterButton.backgroundColor = UIColor.blue
			letterButton.setTitleColor(UIColor.white, for: .normal)
			letterButton.setTitleColor(UIColor.gray, for: .disabled)
			letterButton.setTitle(String(char).capitalized, for: .normal)
			letterButton.layer.borderWidth = 1
			letterButton.layer.borderColor = UIColor.green.cgColor
			letterButtons.append(letterButton)
			letterButton.frame = frame
			buttonsView.addSubview(letterButton)
		}
		
		
		NSLayoutConstraint.activate([
			scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
			scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			
			lifeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 32),
			lifeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			answerLabel.topAnchor.constraint(equalTo: lifeLabel.bottomAnchor, constant: 32),
			answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			buttonsView.widthAnchor.constraint(equalToConstant: 360),
			buttonsView.heightAnchor.constraint(equalToConstant: 200),
			buttonsView.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 32),
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		resetText()
	}
	
	private func resetText() {
		let word = words[level]
		var answer = ""
		for _ in word {
			answer.append("?")
		}
		answerLabel.text = answer
	}


	@objc private func letterTapped(_ sender: UIButton) {
		guard let buttonTitle = sender.titleLabel?.text else { return }
		let word = words[level]
		sender.backgroundColor = UIColor.white
		
		if word.contains(buttonTitle) {
			var answerText = answerLabel.text
			
			for (index, char) in word.enumerated() {
				if String(char) == buttonTitle {
					answerText = (answerText?.prefix(index) ?? "") + buttonTitle + (answerText?.dropFirst(index + 1) ?? "")
				}
			}
			answerLabel.text = answerText
			
			score += 1
		} else {
			life -= 1
			sender.layer.borderColor = UIColor.red.cgColor
		}
		
		sender.isEnabled = false
		checkGame()
	}
	
	private func checkGame() {
		let word = words[level]
		if answerLabel.text == word {
			if level == 6 {
				let vc = UIAlertController(title: "Won!", message: "You are champion", preferredStyle: .alert)
				vc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				present(vc, animated: true, completion: nil)
			} else {
				let vc = UIAlertController(title: "Next Level", message: "Do you want to go to next level?", preferredStyle: .alert)
				vc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nextLevel))
				vc.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
				present(vc, animated: true, completion: nil)
			}
			
			
			return
		}
		
		if life == 0 {
			let vc = UIAlertController(title: "Game over", message: "You are end of this game", preferredStyle: .alert)
			vc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			present(vc, animated: true, completion: nil)
		}
	}
	
	private func nextLevel(action: UIAlertAction) {
		level += 1
		resetText()
		letterButtons.forEach {
			$0.isEnabled = true
			$0.backgroundColor = UIColor.blue
			$0.layer.borderColor = UIColor.green.cgColor
		}
	}
}

