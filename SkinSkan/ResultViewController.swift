//
//  ResultViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/22/22.
//

import Foundation
import UIKit

class ResultViewController: UIViewController {
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var resultLabel: UILabel!
    var chosenImage: UIImage?
    var predictionResult: String?
    
    func configure(chosenImage: UIImage, predictionResult: String) {
        self.chosenImage = chosenImage
        self.predictionResult = predictionResult
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let chosenImage = chosenImage {
            self.photoView.image = chosenImage
        }
        
        if let predictionResult = predictionResult {
            self.resultLabel.text = predictionResult
        }
    }
}

