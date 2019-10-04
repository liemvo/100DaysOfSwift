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
			webView.load(URLRequest(url: URL())
		}
	}
}
