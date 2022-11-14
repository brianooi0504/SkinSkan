//
//  InformationDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/5/22.
//

import Foundation
import UIKit

/// View controller class to display detailed information about the disease chosen
/// Contains a Container View housing the InformationDetailTableViewController
class InformationDetailViewController: UIViewController {
    // MARK: Variables
    private var disease: Disease!
    /// All images of the disease to be displayed in the Collection View
    private var diseaseImages: [UIImage] = []
    
    // MARK: IBOutlets
    /// References the CollectionView
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Rounds the corner of the CollectionView
        self.collectionView.layer.cornerRadius = 8
    }
    
    /// Obtains disease information from InformationViewController or ResultViewController and configures the view controller
    func configure(disease: Disease) {
        self.disease = disease
        self.title = disease.name
        self.diseaseImages = disease.images
    }
    
    /// Prepares the disease and passes it to InformationDetailTableViewController through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InformationDetailTableSegue" {
            let destination = segue.destination as! InformationDetailTableViewController
            destination.configure(disease: disease)
        }
    }
}

extension InformationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource Methods
    /// Returns the number of cells in CollectionView
    /// Returns 1 for the 'No Images Found' image if images are unavailable
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if diseaseImages.count == 0 {
            return 1
        }
        return diseaseImages.count
    }
    
    /// Configures each CollectionViewCell as InfoImageCollectionViewCell class instances using InfoImageCollectionViewCell identifier
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoImageCollectionViewCell", for: indexPath) as! InfoImageCollectionViewCell
        
        /// Displays a 'No Images Found' image if images are unavailable
        if diseaseImages.count != 0{
            cell.imageView.image = diseaseImages[indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "NoImages")
        }
        cell.layer.cornerRadius = 8
        
        return cell
    }
}
