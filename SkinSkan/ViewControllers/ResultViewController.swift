//
//  ResultViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/22/22.
//

import Foundation
import UIKit

/// View controller class to display prediction result using Prediction object
class ResultViewController: UIViewController {
    // MARK: Variables
    var predictionResult: Prediction?
    var predDiseaseIndex: Int?
    /// All disease information obtained from the static Diseases variable in InformationViewController
    let allDiseases = InformationViewController.diseases
    
    // MARK: IBOutlets
    /// References the image view and result text label
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var resultLabel: UILabel!
    
    // MARK: IBActions
    /// For the Find Dermatologists button
    /// Displays the NearbyViewController by switching to the third tab (index 2)
    @IBAction func findDermatologists(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }
    
    /// For the Read More button
    /// Initializes a InformationDetailViewController and displays as a pop up for disease information
    @IBAction func readMoreInfo(_ sender: Any) {
        if let predDiseaseIndex = predDiseaseIndex {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "InformationDetailViewController") as? InformationDetailViewController else { return }
            
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
            vc.configure(disease: allDiseases[predDiseaseIndex])
            let navController = UINavigationController(rootViewController: vc)
            present(navController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Displays the image used in prediction in the image view and the formatted result string in the text label
        if let predictionResult = predictionResult {
            self.photoView.image = predictionResult.image
            
            let formattedPredictions = formatPredictions(predictionResult: predictionResult)

            let predictionString = formattedPredictions.joined(separator: "\n\n")
            self.resultLabel.text = predictionString
        }
    }
    
    /// Obtains prediction result information from TestViewController or ProfileViewController and configures the view controller
    func configure(predictionResult: Prediction) {
        self.predictionResult = predictionResult
    }
    
    // MARK: Self-Defined Functions
    /// Combines each of the two predicted diseases and their confidences as two separate lines
    func formatPredictions(predictionResult: Prediction) -> [String]{
        var predString: [String] = []
        
        let diseases = predictionResult.results
        let confs = predictionResult.confidences
        
        for i in 0 ..< diseases.count {
            predString.append("\(diseases[i]) - \(String(format: "%.1f", confs[i]))% confidence")
        }
        
        /// Sets the index for the disease in the Diseases array to be used for disease information pop up
        predDiseaseIndex = findDiseaseIndex(name: diseases[0])

        return predString
    }
    
    /// Finds the index for the top predicted disease in the static Diseases array stored in InformationViewController
    func findDiseaseIndex(name: String) -> Int {
        for i in 0 ..< allDiseases.count {
            if name == allDiseases[i].name {
                return i
            }
        }
        
        return 0
    }
    
    /// Method called to dismiss the disease information pop up
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
}

