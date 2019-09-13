//
//  DetailViewController.swift
//  Project9
//
//  Created by Liem Vo on 9/8/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

	var webView: WKWebView!
	var detailItem: Petition?
	
	override func loadView() {
		webView = WKWebView()
		view = webView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		showData()
	}
	
	private func showData() {
		guard let detailItem = detailItem else { return }
		
		let html = """
		<html>
		<head>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<style> body { font-size: 150%; } </style>
		<title>\(detailItem.title)</title>
		</head>
		<body>
		\(detailItem.body)
		</body>
		</html>
		"""
		
		webView.loadHTMLString(html, baseURL: nil)
	}

}
