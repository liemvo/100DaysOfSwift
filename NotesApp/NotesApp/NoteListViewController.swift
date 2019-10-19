//
//  NoteListViewController.swift
//  NotesApp
//
//  Created by Liem Vo on 20/10/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class NoteListViewController: UITableViewController {
	
	private var notes: [Note]? = nil
	private let noteManager: NoteManagerProtocol = (UIApplication.shared.delegate as! AppDelegate).noteManager
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Notes"
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		notes = noteManager.loadNotes()
		tableView.reloadData()
	}
	
	@IBAction func addNoteTapped(_ sender: Any) {
		openDetailNote(nil)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notes?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
		
		if let note = notes?[indexPath.row] {
			cell.textLabel?.text = note.title
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let note = notes?[indexPath.row]
		openDetailNote(note)
	}
	
	private func openDetailNote(_ note: Note?) {
		if let noteViewController = storyboard?.instantiateViewController(withIdentifier: "notevc") as? NoteViewController {
			noteViewController.note = note
            navigationController?.pushViewController(noteViewController, animated: true)
        }
	}
}
