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
    var predictionResult: Prediction?
    var predDiseaseIndex: Int?
    let allDiseases = InformationViewController.diseases
    
    func configure(predictionResult: Prediction) {
        self.predictionResult = predictionResult
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let predictionResult = predictionResult {
            self.photoView.image = predictionResult.image
            
            let formattedPredictions = formatPredictions(predictionResult: predictionResult)

            let predictionString = formattedPredictions.joined(separator: "\n\n")
            self.resultLabel.text = predictionString
        }
    }
    
    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(predictionResult: Prediction) -> [String]{
        var predString: [String] = []
        
        let diseases = predictionResult.results
        let confs = predictionResult.confidences
        
        for i in 0 ..< diseases.count {
            predString.append("\(diseases[i]) - \(String(format: "%.1f", confs[i]))% confidence")
        }
        
        predDiseaseIndex = findDiseaseIndex(name: diseases[0])

        return predString
    }
    
    @IBAction func findDermatologists(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func readMoreInfo(_ sender: Any) {
        if let predDiseaseIndex = predDiseaseIndex {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "InformationDetailViewController") as? InformationDetailViewController else { return }
            
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
            vc.configure(disease: allDiseases[predDiseaseIndex])
            let navController = UINavigationController(rootViewController: vc)
            present(navController, animated: true)
        }
    }
    
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func findDiseaseIndex(name: String) -> Int {
        for i in 0 ..< allDiseases.count {
            if name == allDiseases[i].name {
                return i
            }
        }
        
        return 0
    }
}

