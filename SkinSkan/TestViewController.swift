//
//  TestViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/28/22.
//

import Foundation
import UIKit

class TestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var choosePhotoButton: UIButton!
    @IBOutlet var startTestButton: UIButton!
    let userDefaults = UserDefaults.standard
    let SAVE_HISTORY_KEY = "saveHistoryKey"
    
    var chosenImage: UIImage?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let imagePredictor = ImageClassifier()

    /// The largest number of predictions the main view controller displays the user.
    let predictionsToShow = 2
    
    var predictionResult: Prediction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.choosePhotoButton.configuration?.cornerStyle = .dynamic
    }
    
    @IBAction func selectImage(sender: UIButton) {
        ImagePickerManager().pickImage(self){ image in
            self.chosenImage = image
            self.choosePhotoButton.setBackgroundImage(self.chosenImage, for: .normal)
            self.choosePhotoButton.contentMode = .scaleAspectFill
            self.choosePhotoButton.setTitle("", for: .normal)
        }
    }

    @IBAction func removeChosenPhoto() {
        self.chosenImage = nil
        self.choosePhotoButton.setBackgroundImage(nil, for: .normal)
        self.choosePhotoButton.setTitle("Select Image", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultSegue" {
            if let chosenImage = self.chosenImage {
                self.classifyImage(chosenImage)
            }
            
            let destination = segue.destination as! ResultViewController
            if let predictionResult = self.predictionResult {
                destination.configure(predictionResult: predictionResult)
            }
        }
    }
}

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose image from", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    override init(){
        super.init()
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }

        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }

    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;

        alert.popoverPresentationController?.sourceView = self.viewController!.view

        viewController.present(alert, animated: true, completion: nil)
    }
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.allowsEditing = true
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback?(image)
    }

}

extension TestViewController {
    
    // MARK: Image prediction methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image, completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [PredictionResult]?) {
        guard let predictions = predictions else {
            return
        }
        
        let predDiseases = predictions.prefix(predictionsToShow).map { prediction in
            prediction.diseaseName
        }
        
        let predConfidences = predictions.prefix(predictionsToShow).map { prediction in
            prediction.confidencePct
        }
        
        let newPrediction = Prediction(context: self.context)
        if let chosenImage = self.chosenImage {
            newPrediction.image = chosenImage
        }
        newPrediction.datetime = Date()
        newPrediction.results = predDiseases
        newPrediction.confidences = predConfidences
        
        self.predictionResult = newPrediction
        
        if userDefaults.bool(forKey: SAVE_HISTORY_KEY) {
            do {
                try self.context.save()
            } catch {
                print("Cannot save data into Core Data")
            }
        }
    }
    
}


