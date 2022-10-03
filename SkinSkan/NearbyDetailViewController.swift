//
//  NearbyDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

class NearbyDetailViewController: UIViewController {
    private var dermatologist: Dermatologist!
    
    @IBOutlet var nearbyDetailImages: UIScrollView!

    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
        self.title = dermatologist.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NearbyDetailTableSegue" {
            let destination = segue.destination as! NearbyDetailTableViewController
            destination.configure(dermatologist: dermatologist)
        }
    }
}

