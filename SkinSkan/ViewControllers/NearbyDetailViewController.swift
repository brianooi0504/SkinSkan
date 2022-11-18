//
//  NearbyDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

/// View controller class to display detailed information about the dermatologist chosen
/// Contains a Container View housing the NearbyDetailTableViewController
class NearbyDetailViewController: UIViewController {
    // MARK: Variables
    private var dermatologist: Dermatologist!
    /// All images of the dermatologist to be displayed in the Collection View
    private var dermImages: [UIImage] = []
    
    // MARK: IBOutlets
    /// References the CollectionView
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.reloadData()
    }
    
    /// Obtains dermatologist information from NearbyViewController and configures the view controller
    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
        self.dermImages = dermatologist.photos
        self.title = dermatologist.title
    }
    
    /// Prepares the dermatologist and passes it to NearbyDetailTableViewController through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NearbyDetailTableSegue" {
            let destination = segue.destination as! NearbyDetailTableViewController
            destination.configure(dermatologist: dermatologist)
        }
    }
    
}

extension NearbyDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource Methods
    /// Returns the number of cells in CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dermImages.count == 0 {
            return 1
        }
        return dermImages.count
    }
    
    /// Configures each CollectionViewCell as NearbyDetailImageCollectionViewCell class instances using NearbyDetailImageCollectionViewCell identifier
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

