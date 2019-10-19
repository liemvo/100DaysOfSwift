//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Liem Vo on 20/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var sharedButton: UIBarButtonItem!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var detailTextView: UITextView!
	
	private let noteManager: NoteManagerProtocol = (UIApplication.shared.delegate as! AppDelegate).noteManager
	
	var note: Note? = nil {
		didSet {
			self.saveButton.isEnabled = (note?.title != nil && note?.detail != nil)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleTextField.delegate = self
		detailTextView.delegate = self
		saveButton.isEnabled = false
		if (note != nil){
			saveButton.title = "Update"
			deleteButton.isEnabled = true
			titleTextField.text = note?.title
			detailTextView.text = note?.detail
		} else {
			deleteButton.isEnabled = false
		}
	}
	
	@IBAction func saveTapped(_ sender: UIBarButtonItem) {
		noteManager.saveNote(note)
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func shareTapped(_ sender: UIBarButtonItem) {
		guard let notNullNote = note else {
			return
		}
		
		let vc = UIActivityViewController(activityItems: [notNullNote.detail as Any], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = sharedButton
		present(vc, animated: true)
	}
	
	@IBAction func deleteTapped(_ sender: UIBarButtonItem) {
		if let note = note {
			noteManager.deleteNote(note)
		}
		navigationController?.popViewController(animated: true)
	}
}

extension NoteViewController: UITextFieldDelegate {
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let oldNote = note {
			note = Note(noteId: oldNote.noteId, title: textField.text, detail: oldNote.detail)
		} else {
			note = Note(title: textField.text)
		}	
	}
}

extension NoteViewController: UITextViewDelegate {
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		return true 
	}
	func textViewDidChange(_ textView: UITextView) {
		if let oldNote = note {
			note = Note(noteId: oldNote.noteId, title: oldNote.title, detail: textView.text)
		} else {
			note = Note(detail: textView.text)
		}
	}
	
}
