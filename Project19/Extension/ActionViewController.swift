//
//  ActionViewController.swift
//  Extension
//
//  Created by Liem Vo on 10/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
	@IBOutlet weak var script: UITextView!
	var pageTitle = ""
	var pageURL = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let scriptsButton = UIBarButtonItem(title: "Scripts", style: .plain, target: self, action: #selector(selectScripts))
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		navigationItem.setRightBarButtonItems([doneButton, scriptsButton], animated: true)
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		
		if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
			if let itemProvider = inputItem.attachments?.first {
				itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
					guard let itemDictionary = dict as? NSDictionary else { return }
					guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
					print(javaScriptValues)
					
					self?.pageTitle = javaScriptValues["title"] as? String ?? ""
					self?.pageURL = javaScriptValues["URL"] as? String ?? ""

					DispatchQueue.main.async {
						self?.title = self?.pageTitle
						
					}
				}
			}
		}
    }

    @objc private func done() {
        let item = NSExtensionItem()
		let argument: NSDictionary = ["customJavaScript": script.text]
		let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
		let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
		item.attachments = [customJavaScript]

		let userDefault = UserDefaults.standard
		if self.pageURL.count > 0 {
			userDefault.set(URL.init(string: script.text), forKey: self.pageURL)
		}
		
		extensionContext?.completeRequest(returningItems: [item])
    }
	
	@objc private func selectScripts() {
		let ac = UIAlertController(title: "Scripts", message: "", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "Alert title", style: .default, handler: { [weak self] _ in
			self?.script?.text = "alert(document.title);"
		}))
		present(ac, animated: true)
	}
	
	@objc private func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

		let keyboardScreenEndFrame = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			script.contentInset = .zero
		} else {
			script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}

		script.scrollIndicatorInsets = script.contentInset

		let selectedRange = script.selectedRange
		script.scrollRangeToVisible(selectedRange)
	}

}
