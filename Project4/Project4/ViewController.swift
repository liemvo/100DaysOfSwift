//
//  ViewController.swift
//  Project4
//
//  Created by Liem Vo on 8/30/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
	var webView: WKWebView!
	var progressView: UIProgressView!
	var websites = ["apple.com", "hackingwithswift.com"]
	
	override func loadView() {
		webView = WKWebView()
		webView.navigationDelegate = self
		view = webView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		openPage(string: websites[0])
		webView.allowsBackForwardNavigationGestures = true
		
		setupOpenBarItem()
		setupToolbarItems()
		observeProgress()
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		title = webView.title
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let url = navigationAction.request.url
		if let host = url?.host {
			for website in websites {
				if host.contains(website) {
					decisionHandler(.allow)
					return
				}
			}
		}
		
		decisionHandler(.cancel)
	}
	
	private func observeProgress() {
		webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
	}
	
	private func setupOpenBarItem() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .done, target: self, action: #selector(openTapped))
	}
	
	private func setupToolbarItems() {
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
		progressView = UIProgressView(progressViewStyle: .default)
		progressView.sizeToFit()
		let progressButton = UIBarButtonItem(customView: progressView)
		
		toolbarItems = [progressButton, spacer, refresh]
		navigationController?.isToolbarHidden = false
	}
	
	@objc private func openTapped() {
		let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
		websites.forEach {
			ac.addAction(UIAlertAction(title: $0, style: .default, handler: openPage))
		}
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(ac, animated: true)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressView.progress = Float(webView.estimatedProgress)
		}
	}
	
	private func openPage(action: UIAlertAction) {
		openPage(string: action.title!)
	}
	
	private func openPage(string: String){
		let url = URL(string: "https://\(string)")!
		webView.load(URLRequest(url: url))
	}
}

