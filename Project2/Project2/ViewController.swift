//
//  ViewController.swift
//  Project2
//
//  Created by Liem Vo on 8/26/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton?
    @IBOutlet weak var button2: UIButton?
    @IBOutlet weak var button3: UIButton?
	
	var buttons = [UIButton?]()
    
    private var countries = [String]()
    private var score = 0
    
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

	private func askQuestion() {
		for (index, button) in [button1, button2, button3].enumerated() {
			button?.setImage(UIImage(named: countries[index]), for: .normal)
		}
	}
    
}

