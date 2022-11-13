//
//  Disease.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/3/22.
//

import Foundation
import UIKit

/// Struct to store disease information for the InformationViewControllers
struct Disease {
    let name: String
    let desc: String
    let similar: String
    let symptom: String
    let treatment: String
    let link: String
    let images: [UIImage]
}

/// Struct to store prediction result obtained from the image classifier before being stored in the Prediction class supported by Core Data
struct PredictionResult {
    let diseaseName: String
    let confidencePct: Double
}
