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
	var repository: RepositoryProtocol = Repository()
	var scripts: [URL]? = nil
	var loadScript: URL? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
		scripts = repository.loadScripts()
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let savedUrl = repository.loadSaveURL(), let saveScripts = scripts {
			if let index = saveScripts.firstIndex(where: {$0.url == savedUrl}) {
				loadScript = saveScripts[index]
				script.text = loadScript?.script
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		loadScript = nil
		repository.clearLoad()
	}

    @objc private func done() {
        let item = NSExtensionItem()
		let argument: NSDictionary = ["customJavaScript": script.text]
		let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
		let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
		item.attachments = [customJavaScript]

		extensionContext?.completeRequest(returningItems: [item])
    }
	
	@objc private func selectScripts() {
		if let scriptsTable = storyboard?.instantiateViewController(withIdentifier: "scriptsTable") as? ScriptsTableViewController {
            navigationController?.pushViewController(scriptsTable, animated: true)
        }
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

	@IBAction func save(_ sender: Any) {
		if let saveScripts = scripts {
			if let _ = saveScripts.firstIndex(where: {$0.url == pageURL}) {
				let newScripts = saveScripts.map{ $0.url == pageURL ? $0.updateScript(script.text) : $0 }
				repository.saveScripts(newScripts)
			} else {
				var newScripts = saveScripts
				newScripts.append(URL(title: pageTitle, url: pageURL, script: script.text))
				repository.saveScripts(newScripts)
			}
		} else {
			repository.saveScripts([URL(title: pageTitle, url: pageURL, script: script.text)])
		}
	}
}
