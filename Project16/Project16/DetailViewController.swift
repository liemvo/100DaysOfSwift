//
//  DetailViewController.swift
//  Project16
//
//  Created by Liem Vo on 10/4/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import WebKit
import UIKit

class DetailViewController: UIViewController {
	var capital: Capital?
	@IBOutlet weak var webView: WKWebView!
	override func viewDidLoad() {
		super.viewDidLoad()
		if let newCapital = capital {
			openPage(newCapital.title ?? "")
		}
	}
	
	private func openPage(_ string: String){
		title = string
		let url = URL(string: "https://en.wikipedia.org/wiki/\(string)")!
		webView.load(URLRequest(url: url))
	}
}
