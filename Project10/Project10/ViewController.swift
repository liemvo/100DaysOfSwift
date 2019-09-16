//
//  ViewController.swift
//  Project10
//
//  Created by Liem Vo on 9/16/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
			fatalError("unable to dequeue PersonCell.")
		}
		
		return cell
	}
}

