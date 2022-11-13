//
//  NearbyDetailImageCollectionViewCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/25/22.
//

import Foundation
import UIKit

/// CollectionViewCell class to display horizontally-scrollable dermatologist images in NearbyDetailViewController
class NearbyDetailImageCollectionViewCell: UICollectionViewCell {
    /// References the image view used to display dermatologist images
    @IBOutlet var imageView: UIImageView!
}

/// CollectionViewCell class to display horizontally-scrollable disease images in InformationDetailViewController
class InfoImageCollectionViewCell: UICollectionViewCell {
    /// References the image view used to display disease images
    @IBOutlet var imageView: UIImageView!
}
