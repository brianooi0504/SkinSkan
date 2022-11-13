//
//  Disease.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/3/22.
//

import Foundation
import UIKit

struct Disease {
    let name: String
    let desc: String
    let similar: String
    let symptom: String
    let treatment: String
    let link: String
    let images: [UIImage]
}

struct PredictionResult {
    let diseaseName: String
    let confidencePct: Double
}
