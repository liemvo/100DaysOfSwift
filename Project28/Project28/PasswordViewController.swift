//
//  PasswordViewController.swift
//  Project28
//
//  Created by Liem Vo on 11/13/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {

	@IBOutlet weak var passwordField: UITextField!
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePassword))
    }
	
	@objc private func savePassword() {
		guard let password = passwordField.text, password.count > 5 else {
			let ac = UIAlertController(title: "Error!", message: "Number of character must be not less than 5", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			present(ac, animated: true)
			return
		}
		
		
		KeychainWrapper.standard.set(password, forKey: "SecretPassword")
		navigationController?.popViewController(animated: true)
	}
    
}
