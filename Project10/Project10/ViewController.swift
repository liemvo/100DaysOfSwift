//
//  ViewController.swift
//  Project10
//
//  Created by Liem Vo on 9/16/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	private var people = [Person]()
	private var renderedPeople = [Person]()
	private var saveButton: UIBarButtonItem!
	private var authenticate: UIBarButtonItem!
	private var addButton: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
		navigationItem.leftBarButtonItem = addButton
		
		saveButton = UIBarButtonItem(title: "Lock", style: .done, target: self, action: #selector(lockScreen))
		authenticate = UIBarButtonItem(title: "Authorize", style: .done, target: self, action: #selector(authorize))
		
		lockScreen()
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(lockScreen), name: UIApplication.willResignActiveNotification, object: nil)
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return renderedPeople.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
			fatalError("Unable to dequeue PersonCell.")
		}
		let person = renderedPeople[indexPath.row]
		
		cell.name.text = person.name
		
		let path = getDocumentsDirectory().appendingPathComponent(person.image)
		cell.imageView.image = UIImage(contentsOfFile: path.path)
		
		cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
		cell.imageView.layer.borderWidth = 2
		cell.imageView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let person = renderedPeople[indexPath.item]
		
		let ac = UIAlertController(title: "Rename or Delete", message: nil, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (alert: UIAlertAction!) in
			self.renamePerson(person: person)
		}))
		ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (alert: UIAlertAction!) in
			self.renderedPeople.remove(at: indexPath.row)
			self.people.remove(at: indexPath.row)
			self.collectionView.reloadData()
		}))
		
		present(ac, animated: true)
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
		renderedPeople.append(person)
		collectionView.reloadData()
		
		dismiss(animated: true)
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
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
	
	private func renamePerson(person: Person) {
		let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
			guard let newName = ac?.textFields?[0].text else { return }
			person.name = newName
			
			self?.collectionView.reloadData()
		})
		
		present(ac, animated: true)
	}
	
	@objc private func lockScreen() {
		renderedPeople = []
		self.collectionView.reloadData()
		
		navigationItem.leftBarButtonItem = nil
		navigationItem.rightBarButtonItem = authenticate
	}
	
	private func unlock() {
		renderedPeople = people
		self.collectionView.reloadData()
		navigationItem.leftBarButtonItem = addButton
		navigationItem.rightBarButtonItem = saveButton
	}
	
	@objc private func authorize() {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Identify yourself!"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
				DispatchQueue.main.async {
					if success {
						self?.unlock()
					} else {
						let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
						ac.addAction(UIAlertAction(title: "OK", style: .default))
						self?.present(ac, animated: true)
					}
				}
			}
		} else {
			// no biometry
			
			let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(ac, animated: true)
			
		}
	}
}

