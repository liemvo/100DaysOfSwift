//
//  TodoManager.swift
//  NotesApp
//
//  Created by Liem Vo on 20/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//
import UIKit

protocol NoteManagerProtocol {
	func loadNotes() -> [Note]
	func saveNote(_ note: Note?)
	func deleteNote(_ note: Note)
}

class NoteManager: NoteManagerProtocol {
	private var notes = [Note]()
	
	init() {
		readNotes()
	}
	
	func loadNotes() -> [Note] {
		return notes
	}
	
	func saveNote(_ newNote: Note?) {
		guard let note = newNote else {
			return
		}
		
		let count = notes.filter { $0.noteId == note.noteId }.count
		if count > 0 {
			notes = notes.map { $0.noteId == note.noteId ? note : $0}
		} else {
			notes.insert(note, at: 0)
		}
		writeNotes(notes)
	}
	
	func deleteNote(_ note: Note) {
		let index = notes.firstIndex(of: note)
		if let index = index {
			notes.remove(at: index)
			writeNotes(notes)
		}
	}
	private func readNotes() {
		let defaults = UserDefaults.standard
		
		if let savedNotes = defaults.object(forKey: "notes") as? Data {
			let jsonDecoder = JSONDecoder()
			
			do {
				notes = try jsonDecoder.decode([Note].self, from: savedNotes)
			} catch {
				print("Failed to load note")
			}
		}
	}
	
	private func writeNotes(_ notes: [Note]?) {
		if let saveNotes = notes {
			let jsonEncoder = JSONEncoder()
			if let savedData = try? jsonEncoder.encode(saveNotes) {
				let defaults = UserDefaults.standard
				defaults.set(savedData, forKey: "notes")
			} else {
				print("failed to save people")
			}
		}
	}
}
