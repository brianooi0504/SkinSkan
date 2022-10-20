//
//  InformationDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/5/22.
//

import Foundation
import UIKit

class InformationDetailViewController: UIViewController {
    private var disease: Disease!
    
    func configure(disease: Disease) {
        self.disease = disease
        self.title = disease.name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InformationDetailTableSegue" {
            let destination = segue.destination as! InformationDetailTableViewController
            destination.configure(disease: disease)
        }
    }
}
