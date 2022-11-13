//
//  NearbyDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

class NearbyDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var dermatologist: Dermatologist!
    private var dermImages: [UIImage] = []

    @IBOutlet var collectionView: UICollectionView!
    
    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
        self.dermImages = dermatologist.photos
        self.title = dermatologist.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NearbyDetailTableSegue" {
            let destination = segue.destination as! NearbyDetailTableViewController
            destination.configure(dermatologist: dermatologist)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dermImages.count == 0 {
            return 1
        }
        return dermImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyDetailImageCollectionViewCell", for: indexPath) as! NearbyDetailImageCollectionViewCell
        
        if dermImages.count != 0{
            cell.imageView.image = dermImages[indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "NoImages")
        }
        
        return cell
    }
    
}

