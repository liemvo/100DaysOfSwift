//
//  AppDelegate.swift
//  NotesApp
//
//  Created by Liem Vo on 20/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let noteManager: NoteManagerProtocol = NoteManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
	
}

