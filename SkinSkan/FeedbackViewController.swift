//
//  FeedbackViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/13/22.
//

import Foundation
import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.textView.delegate = self
        
        self.textView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.cornerRadius = 8
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        if nameTextField.text!.isEmpty || emailTextField.text!.isEmpty || textView.text.isEmpty {
            let incompleteAlert = UIAlertController(title: "Warning!", message: "Feedback form incomplete!", preferredStyle: UIAlertController.Style.alert)
            incompleteAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(incompleteAlert, animated: true, completion: nil)
        } else if !NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: emailTextField.text) {
            let invalidAlert = UIAlertController(title: "Warning!", message: "Email address invalid!", preferredStyle: UIAlertController.Style.alert)
            invalidAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(invalidAlert, animated: true, completion: nil)
        } else {
            nameTextField.text = ""
            emailTextField.text = ""
            textView.text = ""
            
            let alert = UIAlertController(
                title: "Thank You!",
                message: "Your feedback has been sent!",
                preferredStyle: UIAlertController.Style.alert
            )
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
