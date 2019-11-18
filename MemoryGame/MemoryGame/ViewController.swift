//
//  ViewController.swift
//  MemoryGame
//
//  Created by Liem Vo on 11/18/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var button4: UIButton!
	@IBOutlet weak var button5: UIButton!
	@IBOutlet weak var button6: UIButton!
	
	@IBOutlet weak var button7: UIButton!
	@IBOutlet weak var button8: UIButton!
	@IBOutlet weak var button9: UIButton!
	@IBOutlet weak var button10: UIButton!
	@IBOutlet weak var button11: UIButton!
	@IBOutlet weak var button12: UIButton!
	
	@IBOutlet weak var button13: UIButton!
	@IBOutlet weak var button14: UIButton!
	@IBOutlet weak var button15: UIButton!
	@IBOutlet weak var button16: UIButton!
	@IBOutlet weak var button17: UIButton!
	@IBOutlet weak var button18: UIButton!
	
	@IBOutlet weak var button19: UIButton!
	@IBOutlet weak var button20: UIButton!
	@IBOutlet weak var button21: UIButton!
	@IBOutlet weak var button22: UIButton!
	@IBOutlet weak var button23: UIButton!
	@IBOutlet weak var button24: UIButton!
	
	@IBOutlet weak var button25: UIButton!
	@IBOutlet weak var button26: UIButton!
	@IBOutlet weak var button27: UIButton!
	@IBOutlet weak var button28: UIButton!
	@IBOutlet weak var button29: UIButton!
	@IBOutlet weak var button30: UIButton!
	
	@IBOutlet weak var button31: UIButton!
	@IBOutlet weak var button32: UIButton!
	@IBOutlet weak var button33: UIButton!
	@IBOutlet weak var button34: UIButton!
	@IBOutlet weak var button35: UIButton!
	@IBOutlet weak var button36: UIButton!
	
	private var buttons = [UIButton]()
	
	private let countries = ["Albania", "Andorra", "Armenia", "Austria", "Azerbaijan"]
	private let capitalCities = ["Tirana", "Andorra la Vella", "Yerevan",  "Vienna", "Baku"]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		buttons = [button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16, button17, button18, button19, button20, button21, button22, button23, button24, button25, button26, button27, button28, button29, button30, button31, button32, button33, button34, button35, button36]
		
		for i in 0 ..< buttons.count {
			let button = buttons[i]
			button.tag = 100 + i
			button.setTitle("", for: .normal)
			button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		}
	}
	@IBAction func buttonTapped(_ sender: UIButton) {
		print("Touch at \(sender.tag)")
	}
	
}

