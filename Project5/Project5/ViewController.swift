//
//  ViewController.swift
//  Project5
//
//  Created by Liem Vo on 9/1/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	
	var allWords = [String]()
	var usedWords = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadWords()
		loadGame()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
	}
	
	private func loadGame() {
		let defaults = UserDefaults.standard
		usedWords = defaults.array(forKey: "usedWords") as? [String] ?? []
		title = defaults.value(forKey: "currentWord") as? String ?? allWords.randomElement()
		UserDefaults.standard.set(title, forKey: "currentWord")
		tableView.reloadData()
	}
	
	private func save() {
		let defaults = UserDefaults.standard
		defaults.set(usedWords, forKey: "usedWords")

	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return usedWords.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
		cell.textLabel?.text = usedWords[indexPath.row]
		return cell
	}
	
	@objc private func promptForAnswer() {
		let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
			guard let answer = ac?.textFields?[0].text else { return }
			self?.submit(answer)
		}
		
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	private func submit(_ answer: String) {
		let lowerAnswer = answer.lowercased()
		if isPossible(word: lowerAnswer) {
			if isOriginal(word: lowerAnswer) {
				if isReal(word: lowerAnswer) {
					usedWords.insert(answer, at: 0)
					let indexPath = IndexPath(row: 0, section: 0)
					tableView.insertRows(at: [indexPath], with: .automatic)
					save()
					return
				} else {
					showError(title: "Word not recognised", message: "You can't just make them up, you know!")
				}
			} else {
				showError(title: "Word used already", message: "Be more original!")
			}
		} else {
			guard let title = title?.lowercased() else { return }
			showError(title: "Word not possible", message: "You can't spell that word from \(title)")
		}
	}
	
	private func showError(title: String, message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
	
	private func isPossible(word: String) -> Bool {
		guard var tempWord = title?.lowercased() else {
			return false
		}
		
		for letter in word {
			if let position = tempWord.firstIndex(of: letter) {
				tempWord.remove(at: position)
			} else {
				return false
			}
		}
		return true
	}
	
	private func isOriginal(word: String) -> Bool {
		return !usedWords.contains(word)
	}
	
	private func isReal(word: String) -> Bool {
		if word.count <= 3 { return false }
		
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
		return misspelledRange.location == NSNotFound
	}
	
	private func loadWords() {
		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
			if let startWords = try? String(contentsOf: startWordsURL) {
				allWords = startWords.components(separatedBy: "\n")
			}
		}
		if allWords.isEmpty {
			allWords = ["silkworm"]
		}
	}
	
	@objc private func startGame() {
		title = allWords.randomElement()
		UserDefaults.standard.set(title, forKey: "currentWord")
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}
}

