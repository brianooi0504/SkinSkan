//
//  TestViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/28/22.
//

import Foundation
import UIKit
import PhotosUI
import AVFoundation

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
            } else {
                let alert = UIAlertController(title: "No image chosen!",
                                              message: "Choose an image and try again!",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: { _ in
                     print("OK tap")
                }))
                present(alert, animated: true, completion: nil)
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
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraAuthorizationStatus {
            case .notDetermined: self.requestCameraPermission()
            case .authorized: self.openCamera()
            case .restricted, .denied: self.alertAccessNeeded(appName: "Camera")
            @unknown default:
               fatalError("Unknown case for camera authorization")
            }
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){ UIAlertAction in
            let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch photoLibraryAuthorizationStatus {
            case .notDetermined: self.requestPhotosPermission()
            case .restricted, .denied: self.alertAccessNeeded(appName: "Photo Library")
            case .authorized, .limited: self.openGallery()
            @unknown default:
                fatalError("Unknown case for photo library authorization")
            }
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
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
            if granted {
                self.openCamera()
            }
        })
    }
    func requestPhotosPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler:  {[unowned self] (status) in
            if status == .authorized {
                openGallery()
            }
            else if status == .limited {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController!)
            }
            else { return }
            
        })
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [self] in
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                picker.allowsEditing = true
                picker.sourceType = .camera
                self.viewController!.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    func alertAccessNeeded(appName: String) {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsAppURL) else {
            assertionFailure("Unable to open App privacy settings")
            return
        }
        
        let alert = UIAlertController(
            title: "SkinSkan Would Like to Access the \(appName)",
            message: "This app requires \(appName) access to obtain pictures for prediction.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Allow \(appName)", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [self] in
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.viewController!.present(picker, animated: true, completion: nil)
        }
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
    
