//
//  ImageCollectionView.swift
//  Project1
//
//  Created by Liem Vo on 9/18/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageCollectionView: UICollectionViewController {

	private var images = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
		performSelector(inBackground: #selector(loadImages), with: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
		navigationItem.title = "Images"

    }
	
	@objc private func loadImages() {
		let fm = FileManager.default
		let path = Bundle.main.resourcePath!
		let items = try! fm.contentsOfDirectory(atPath: path)
		for item in items {
			if item.hasPrefix("img") {
				images.append(item)
			}
		}
		collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
	}
	
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCell else {
			fatalError("Unable to dequeue PersonCell.")
		}
		let imageName = images[indexPath.row]
    	cell.labelText.text = imageName
		cell.imageView.image = UIImage(named: imageName)
		cell.viewsText.text = "Views: \(getViews(name: imageName))"
        return cell
    }

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
			detailViewController.selectedData = SelectData(selectName: images[indexPath.row], position: indexPath.row + 1, count: images.count)
			let imageName = images[indexPath.row]
			let views = getViews(name: imageName) + 1
			saveViews(name: imageName, views: views)
			collectionView.reloadItems(at: [indexPath])
			navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
	
	private func getViews(name imageName: String) -> Int {
		let defaults = UserDefaults.standard
		return defaults.value(forKey: imageName) as? Int ?? 0
	}
	
	private func saveViews(name imageName: String, views: Int) {
		let defaults = UserDefaults.standard
		defaults.set(views, forKey: imageName)
	}
}
