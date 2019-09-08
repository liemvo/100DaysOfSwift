//
//  AppDelegate.swift
//  Project7
//
//  Created by Liem Vo on 9/7/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		if let tabBarController = window?.rootViewController as? UITabBarController {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "NavController")
			vc.tabBarItem = UITabBarItem(tabBarSystemItem: .topRated, tag: 1)
			tabBarController.viewControllers?.append(vc)
		}
		return true
	}
}

