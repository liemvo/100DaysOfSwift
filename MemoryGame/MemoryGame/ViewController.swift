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
	
	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var label3: UILabel!
	@IBOutlet weak var label4: UILabel!
	@IBOutlet weak var label5: UILabel!
	@IBOutlet weak var label6: UILabel!
	
	@IBOutlet weak var label7: UILabel!
	@IBOutlet weak var label8: UILabel!
	@IBOutlet weak var label9: UILabel!
	@IBOutlet weak var label10: UILabel!
	@IBOutlet weak var label11: UILabel!
	@IBOutlet weak var label12: UILabel!
	
	@IBOutlet weak var label13: UILabel!
	@IBOutlet weak var label14: UILabel!
	@IBOutlet weak var label15: UILabel!
	@IBOutlet weak var label16: UILabel!
	@IBOutlet weak var label17: UILabel!
	@IBOutlet weak var label18: UILabel!
	
	@IBOutlet weak var label19: UILabel!
	@IBOutlet weak var label20: UILabel!
	@IBOutlet weak var label21: UILabel!
	@IBOutlet weak var label22: UILabel!
	@IBOutlet weak var label23: UILabel!
	@IBOutlet weak var label24: UILabel!
	
	@IBOutlet weak var label25: UILabel!
	@IBOutlet weak var label26: UILabel!
	@IBOutlet weak var label27: UILabel!
	@IBOutlet weak var label28: UILabel!
	@IBOutlet weak var label29: UILabel!
	@IBOutlet weak var label30: UILabel!
	
	@IBOutlet weak var label31: UILabel!
	@IBOutlet weak var label32: UILabel!
	@IBOutlet weak var label33: UILabel!
	@IBOutlet weak var label34: UILabel!
	@IBOutlet weak var label35: UILabel!
	@IBOutlet weak var label36: UILabel!
	
	private var buttons = [UIButton]()
	private var labels = [UILabel]()
	
	private var countries = [Country]()
	private var currentCountries = [Country]()
	private var previousClick = -1
	@IBOutlet weak var indicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.isUserInteractionEnabled = false
		indicator.isHidden = false
		performSelector(inBackground: #selector(loadData), with: nil)
		
		buttons = [button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16, button17, button18, button19, button20, button21, button22, button23, button24, button25, button26, button27, button28, button29, button30, button31, button32, button33, button34, button35, button36]
		
		labels = [label1, label2, label3, label4, label5, label6, label7, label8, label9, label10, label11, label12, label13, label14, label15, label16, label17, label18, label19, label20, label21, label22, label23, label24, label25, label26, label27, label28, label29, label30, label31, label32, label33, label34, label35, label36]
		
		labels.forEach {
			$0.isHidden = true
			$0.textAlignment = .center
			$0.textColor = .white
			$0.numberOfLines = 0
		}
		
		for i in 0 ..< buttons.count {
			let button = buttons[i]
			button.tag = 100 + i
			button.setTitle("", for: .normal)
			button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		}
	}
	
	@IBAction func buttonTapped(_ sender: UIButton) {
		let currentClick = sender.tag - 100
		perform(#selector(flip), with: (sender, labels[currentClick]), afterDelay: 0)
		if previousClick != -1 {
			let currentCountry = currentCountries[currentClick]
			let previousCountry = currentCountries[previousClick]
			
			if currentCountry.capital == previousCountry.capital {
				
				// show previous card
				perform(#selector(flip), with: (buttons[previousClick], labels[previousClick]), afterDelay: 0)
				
				
				perform(#selector(hide), with: (currentClick, previousClick), afterDelay: 2)
			} else {
				perform(#selector(revert), with: (labels[currentClick], buttons[currentClick]), afterDelay: 2)
			}
			
			previousClick = -1
		} else {
			previousClick = currentClick
			perform(#selector(revert), with: (labels[currentClick], buttons[currentClick]), afterDelay: 2)
		}
		
	}
	
	
	@objc private func loadData() {
		if let jsonURL = Bundle.main.url(forResource: "countries", withExtension: "json") {
			if let data = try? Data(contentsOf: jsonURL) {
				parse(json: data)
				return
			}
		}
	}
	
	private func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let jsonCountries = try? decoder.decode([Country].self, from: json) {
			countries = jsonCountries
			performSelector(onMainThread: #selector(enableUI), with: nil, waitUntilDone: false)
		} else {
			performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
			performSelector(onMainThread: #selector(enableUI), with: nil, waitUntilDone: false)
		}
	}
	
	@objc private func showError() {
		let ac = UIAlertController(title: "Loading error", message: "There was a problem loading data.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
	
	@objc private func enableUI() {
		view.isUserInteractionEnabled = true
		indicator.isHidden = true
		if countries.count > 18 {
			currentCountries = Array(countries.shuffled()[0..<buttons.count/2])
			currentCountries += currentCountries
			currentCountries.shuffle()
			for i in 0 ..< currentCountries.count {
				labels[i].text = currentCountries[i].capital
			}
		} else {
			showError()
		}
	}
	
	@objc func flip(object: Any) {
		if let (firstView, secondView) = object as? (UIView, UIView) {
			let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
			
			UIView.transition(with: firstView, duration: 1.0, options: transitionOptions, animations: {
				firstView.isHidden = true
			})
			
			UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
				secondView.isHidden = false
			})
			
		}
	}
	
	@objc func revert(object: Any) {
		if let (firstView, secondView) = object as? (UIView, UIView) {
			firstView.isHidden = true
			secondView.isHidden = false
		}
	}
	
	@objc func hide(object: Any) {
		if let (currentPosition, previousPosition) = object as? (Int, Int) {
			labels[currentPosition].isHidden = true
			labels[previousPosition].isHidden = true
			
			buttons[currentPosition].isHidden = true
			buttons[previousPosition].isHidden = true
		}
	}
}

