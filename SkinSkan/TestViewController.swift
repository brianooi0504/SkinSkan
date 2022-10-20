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
    var chosenImage: UIImage?
    
    override func viewDidLoad() {
        self.choosePhotoButton.configuration?.cornerStyle = .dynamic
    }
    
    @IBAction func selectImage(sender: UIButton) {
//        showImagePickerControllerActionSheet()
        ImagePickerManager().pickImage(self){ image in
            self.chosenImage = image
            self.choosePhotoButton.setBackgroundImage(self.chosenImage, for: .normal)
            self.choosePhotoButton.setTitle("", for: .normal)
        }
    }


    @IBAction func removeChosenPhoto() {
        self.chosenImage = nil
        self.choosePhotoButton.setBackgroundImage(nil, for: .normal)
        self.choosePhotoButton.setTitle("Select Image", for: .normal)
    }
    
}

//extension TestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func showImagePickerControllerActionSheet() {
//        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) {
//            (action) in self.showImagePickerController(sourceType: .photoLibrary)
//        }
//        let cameraAction = UIAlertAction(title: "Take from camera", style: .default) {
//            (action) in self.showImagePickerController(sourceType: .camera)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
//    }
//
//    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = true
//        imagePickerController.sourceType = sourceType
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            self.chosenImage = editedImage
//            choosePhotoButton.setBackgroundImage(self.chosenImage, for: .normal)
//            choosePhotoButton.setTitle("", for: .normal)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//}

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

