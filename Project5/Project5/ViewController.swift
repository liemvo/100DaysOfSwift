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
		startGame()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
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
	
	private func startGame() {
		title = allWords.randomElement()
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}
}

