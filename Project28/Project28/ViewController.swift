//
//  ViewController.swift
//  Project28
//
//  Created by Liem Vo on 11/12/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
	private var saveButton: UIBarButtonItem!
	private var createButton: UIBarButtonItem!
	
	@IBOutlet weak var authenticateButton: UIButton!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var secret: UITextView!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		showOrHidePasswordForm(isShown: false)
		createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createPassword))
		saveButton = UIBarButtonItem(title: "Lock", style: .done, target: self, action: #selector(saveSecretMessage))
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
	}
	
	@IBAction func authenticateTapped(_ sender: Any) {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Identify yourself!"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
				DispatchQueue.main.async {
					if success {
						self?.unlockSecretMessage()
					} else {
						let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
						ac.addAction(UIAlertAction(title: "OK", style: .default))
						self?.present(ac, animated: true)
					}
				}
			}
		} else {
			// no biometry
			if KeychainWrapper.standard.string(forKey: "SecretPassword")?.count ?? 0 > 5 {
				showOrHidePasswordForm(isShown: true)
			} else {
				let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default))
				self.present(ac, animated: true)
			}
		}
	}
	
	@objc private func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		let keyboardScreenEnd = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
		
		if notification.name == UIResponder.keyboardWillChangeFrameNotification {
			secret.contentInset = .zero
		} else {
			secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}
		
		secret.scrollIndicatorInsets = secret.contentInset
		
		let selectedRange = secret.selectedRange
		secret.scrollRangeToVisible(selectedRange)
	}
	
	private func unlockSecretMessage() {
		navigationItem.rightBarButtonItem = saveButton
		navigationItem.leftBarButtonItem  = createButton
		secret.isHidden = false
		title = "Secret stuff!"
		
		secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
	}
	
	@objc private func saveSecretMessage() {
		guard secret.isHidden == false else { return }
		navigationItem.rightBarButtonItem = nil
		navigationItem.leftBarButtonItem = nil
		KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
		secret.resignFirstResponder()
		secret.isHidden = true
		title = "Nothing to see here"
	}
	
	@objc private func createPassword() {
		if let passwordController = storyboard?.instantiateViewController(withIdentifier: "passwordView") as? PasswordViewController {
			navigationController?.pushViewController(passwordController, animated: true)
		}
	}
	
	
	@IBAction func confirmTapped(_ sender: Any) {
		guard let savePassword = KeychainWrapper.standard.string(forKey: "SecretPassword"), savePassword.count > 5, savePassword == passwordField.text else {
			
			passwordField.text = ""
			
			let ac = UIAlertController(title: "Wrong password", message: "You have enter wrong password!!!", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(ac, animated: true)
			return
		}
		
		passwordField.text = ""
		showOrHidePasswordForm(isShown: false)
		unlockSecretMessage()
	}
	
	private func showOrHidePasswordForm(isShown: Bool) {
		self.passwordField.isHidden = !isShown
		self.confirmButton.isHidden = !isShown
		
		self.authenticateButton.isHidden = isShown
	}
}

