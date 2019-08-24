//
//  DetailViewController.swift
//  Project1
//
//  Created by Liem Vo on 8/24/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selectedData: SelectData?
    @IBOutlet weak var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = selectedData {
            imageView?.image = UIImage(named: data.selectName)
            title = "\(data.position) of \(data.count)"
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
