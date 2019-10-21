//
//  Note.swift
//  NotesApp
//
//  Created by Liem Vo on 20/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class Note: NSObject, Codable {
	let title: String?
	let detail: String?
	let noteId: String
	
	init(noteId: String = UUID.init().uuidString, title: String? = nil, detail: String? = nil) {
		self.noteId = noteId
		self.title = title
		self.detail = detail
	}

}

