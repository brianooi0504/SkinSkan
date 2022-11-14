//
//  InformationDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/5/22.
//

import Foundation
import UIKit

class InformationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var disease: Disease!
    private var diseaseImages: [UIImage] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
    func configure(disease: Disease) {
        self.disease = disease
        self.title = disease.name
        self.diseaseImages = disease.images
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.layer.cornerRadius = 8
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InformationDetailTableSegue" {
            let destination = segue.destination as! InformationDetailTableViewController
            destination.configure(disease: disease)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if diseaseImages.count == 0 {
            return 1
        }
        return diseaseImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoImageCollectionViewCell", for: indexPath) as! InfoImageCollectionViewCell
        
        if diseaseImages.count != 0{
            cell.imageView.image = diseaseImages[indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "NoImages")
        }
        cell.layer.cornerRadius = 8
        
        return cell
    }
}
