//
//  ViewController.swift
//  Challenge1012
//
//  Created by Liem Vo on 9/23/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var people = [Person]()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
		loadSavedPeople()
	}

	@objc private func addNewPerson() {
		let picker = UIImagePickerController()
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		}
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	private func loadSavedPeople() {
		let defaults = UserDefaults.standard
		
		if let savedPeople = defaults.object(forKey: "people") as? Data {
			let jsonDecoder = JSONDecoder()
			
			do {
				people = try jsonDecoder.decode([Person].self, from: savedPeople)
			} catch {
				print("Failed to load people")
			}
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }
		
		let imageName = UUID().uuidString
		let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
		
		if let jpegData = image.jpegData(compressionQuality: 0.8) {
			try? jpegData.write(to: imagePath)
		}
		
		let person = Person(name: "Unknow", image: imageName)
		people.append(person)
		tableView.reloadData()
		self.save()
		dismiss(animated: true)
	}
	
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	private func save() {
		let jsonEncoder = JSONEncoder()
		if let savedData = try? jsonEncoder.encode(people) {
			let defaults = UserDefaults.standard
			defaults.set(savedData, forKey: "people")
		} else {
			print("failed to save people")
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return people.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "photocell", for: indexPath) as! ItemCell
		let person = people[indexPath.row]
		cell.captionText.text = person.name
		
		let path = getDocumentsDirectory().appendingPathComponent(person.image)
		cell.photoView.image = UIImage(contentsOfFile: path.path)
		
		cell.photoView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
		cell.photoView.layer.borderWidth = 2
		cell.photoView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7
		return cell
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let person = people[indexPath.item]
		
		let ac = UIAlertController(title: "Rename or Goto Detail", message: nil, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (alert: UIAlertAction!) in
			self.renamePerson(person: person)
		}))
		ac.addAction(UIAlertAction(title: "Goto Detail", style: .default) { [weak self] _ in
			if let detailsViewController = self?.storyboard?.instantiateViewController(identifier: "detailsView") as? DetailsViewController {
				detailsViewController.person = self?.people[indexPath.row]
				self?.navigationController?.pushViewController(detailsViewController, animated: true)
			}
		})
		present(ac, animated: true)
	}
	
	private func renamePerson(person: Person) {
		let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
			guard let newName = ac?.textFields?[0].text else { return }
			person.name = newName
			
			self?.tableView.reloadData()
			self?.save()
		})
		
		present(ac, animated: true)
	}
}

