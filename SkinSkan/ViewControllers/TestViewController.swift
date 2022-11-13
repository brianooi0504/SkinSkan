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

/// View controller class for the page where user picks an image and is then passed to the image classification model
/// The results obtained will then be passed to the next view controller - ResultViewController to be displayed to the user
class TestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Variables
    /// Variables for UserDefaults for the Save History setting
    let userDefaults = UserDefaults.standard
    let SAVE_HISTORY_KEY = "saveHistoryKey"
    
    /// Variables for image classifier
    var chosenImage: UIImage?
    /// A Prediction object to be saved to Core Data depending on the Save History setting
    var predictionResult: Prediction?
    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let imagePredictor = ImageClassifier()
    /// The maximum number of predictions displayed to the user.
    let predictionsToShow = 2
    
    /// Variable for Core Data to save prediction results
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: IBOutlets
    /// References the Select Image button and Start Test button
    @IBOutlet var choosePhotoButton: UIButton!
    @IBOutlet var startTestButton: UIButton!
    
    // MARK: IBActions
    /// For Select Image button
    /// To get image from ImagePickerManager and sets it as the Select Image button background
    @IBAction func selectImage(sender: UIButton) {
        ImagePickerManager().pickImage(self){ image in
            self.chosenImage = image
            self.choosePhotoButton.setBackgroundImage(self.chosenImage, for: .normal)
            self.choosePhotoButton.contentMode = .scaleAspectFill
            self.choosePhotoButton.setTitle("", for: .normal)
        }
    }

    /// For Remove Image button
    /// Resets the chosenImage variable and Select Image button
    @IBAction func removeChosenPhoto() {
        self.chosenImage = nil
        self.choosePhotoButton.setBackgroundImage(nil, for: .normal)
        self.choosePhotoButton.setTitle("Select Image", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Gives the Select Image button rounded corners
        self.choosePhotoButton.layer.cornerRadius = 8
    }
    
    /// Prepares the result and passes it to ResultViewController through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultSegue" {
            /// Passes the chosen image through the image classifier to get Prediction object as result
            if let chosenImage = self.chosenImage {
                self.classifyImage(chosenImage)
            } else {
                /// Error checking for if image is chosen, alert is displayed
                let alert = UIAlertController(title: "No image chosen!", message: "Choose an image and try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in print("OK tap")}))
                present(alert, animated: true, completion: nil)
            }
            /// Sets segue destination and passes the resultant Prediction object to the ResultViewController
            let destination = segue.destination as! ResultViewController
            if let predictionResult = self.predictionResult {
                destination.configure(predictionResult: predictionResult)
            }
        }
    }
}

extension TestViewController {
    // MARK: Image Prediction Methods
    /// Sends an image to the image classifier to get a prediction of its content
    /// The completion handler imagePredictionHandler is called after prediction is obtained
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image, completionHandler: imagePredictionHandler)
        } catch {
            print("The image classifier was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    /// The method the image classifier calls after the image classifier model generates a prediction
    private func imagePredictionHandler(_ predictions: [PredictionResult]?) {
        guard let predictions = predictions else {
            return
        }
        
        /// Only the top 2 predictions are used
        /// The results are separated into two arrays, one for disease names and the other for confidence percentages
        /// This is to match the Core Data structure to be saved into persistent storage
        let predDiseases = predictions.prefix(predictionsToShow).map { prediction in
            prediction.diseaseName
        }
        
        let predConfidences = predictions.prefix(predictionsToShow).map { prediction in
            prediction.confidencePct
        }
        
        /// Creates new Prediction object with chosen image, current date time, disease and confidence from results
        let newPrediction = Prediction(context: self.context)
        if let chosenImage = self.chosenImage {
            newPrediction.image = chosenImage
        }
        newPrediction.datetime = Date()
        newPrediction.results = predDiseases
        newPrediction.confidences = predConfidences
        
        self.predictionResult = newPrediction
        
        /// Checks UserDefaults and if necessary, saves the Prediction object to Core Data
        if userDefaults.bool(forKey: SAVE_HISTORY_KEY) {
            do {
                try self.context.save()
            } catch {
                print("Cannot save data into Core Data")
            }
        }
    }
}

// MARK: - Image Picker Class
class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// Variables for Image Picker object
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose image from", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?
    
    override init(){
        super.init()
        /// Adds camera action option for user to pick image from
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            /// Checks camera permissions
            switch cameraAuthorizationStatus {
                /// If not chosen, asks from user
            case .notDetermined: self.requestCameraPermission()
                /// If allowed, open camera
            case .authorized: self.openCamera()
                /// If denied, shows alert again, letting user know that camera permission is needed
            case .restricted, .denied: self.accessNeededAlert(appName: "Camera")
            @unknown default:
               fatalError("Unknown case for camera authorization")
            }
        }
        /// Adds photo library action option for user to pick image from
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default){ UIAlertAction in
            let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            /// Checks photo library permissions
            switch photoLibraryAuthorizationStatus {
            case .notDetermined: self.requestPhotosPermission()
            case .restricted, .denied: self.accessNeededAlert(appName: "Photo Library")
            case .authorized, .limited: self.openGallery()
            @unknown default:
                fatalError("Unknown case for photo library authorization")
            }
        }
        /// Cancel action option to dismiss image picker selection
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
            
        /// Add the action actions to the image picker selection
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }
    
    // MARK: Privacy Permissions
    /// Asks user for permission to access camera
    /// If granted, opens the camera
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
            if granted {
                self.openCamera()
            }
        })
    }
    
    /// Asks user for permission to access photo library
    /// If granted fully, opens the photo library
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
    
    /// Presents the camera as a popup on the main thread
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
    
    /// Presents the photo library as a popup on the main thread
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [self] in
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.viewController!.present(picker, animated: true, completion: nil)
        }
    }
    
    /// Displays an alert asking user to go to Settings page for the app to change permissions to camera or photo library
    func accessNeededAlert(appName: String) {
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
        
        /// If user wants to change permission settings, the Settings page for the app will appear
        alert.addAction(UIAlertAction(title: "Allow \(appName)", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Image Picker Methods
    /// Initialising the Image Picker object, by setting the root view controller and callback (method to call after image is picked)
    /// Then shows the image picker selection pop up
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Cancel button in image picker that dismisses the image picker pop up
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Method called after an image is picked
    /// Dismisses the image picker and then returns the edited (cropped) image from the selected image Dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback?(image)
    }
    
}
