//
//  ViewController.swift
//  Project10
//
//  Created by Liem Vo on 9/16/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	var people = [Person]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
		
	}

	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return people.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
			fatalError("Unable to dequeue PersonCell.")
		}
		let person = people[indexPath.row]
		
		
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
		let person = people[indexPath.item]
		
		let ac = UIAlertController(title: "Rename or Delete", message: nil, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (alert: UIAlertAction!) in
			self.renamePerson(person: person)
		}))
		ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (alert: UIAlertAction!) in
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
}

