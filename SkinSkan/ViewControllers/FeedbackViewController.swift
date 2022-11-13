//
//  FeedbackViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/13/22.
//

import Foundation
import UIKit

/// View controller class to display a pop up that allows users to enter their information and feedback/comments
/// The form details will not be sent to the app developers as it is NOT implemented at this stage
class FeedbackViewController: UIViewController {
    // MARK: IBOutlets
    /// References the Text Fields for Name, Email, and the Text View for user feedback
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var textView: UITextView!
    
    // MARK: IBActions
    /// For top right Send bar button
    /// Sends the user information and feedback to the app developers but is NOT implemented at this stage
    /// Clears out all text fields/views after sending for the next feedback
    @IBAction func sendFeedback(_ sender: Any) {
        /// Displays an alert if any of the text fields/views is empty
        if nameTextField.text!.isEmpty || emailTextField.text!.isEmpty || textView.text.isEmpty {
            let incompleteAlert = UIAlertController(title: "Warning!",
                                                    message: "Feedback form incomplete!",
                                                    preferredStyle: UIAlertController.Style.alert)
            incompleteAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(incompleteAlert, animated: true, completion: nil)
        }
        /// Displays an alert if email entered is invalid
        else if !NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: emailTextField.text) {
            
            let invalidAlert = UIAlertController(title: "Warning!",
                                                 message: "Email address invalid!",
                                                 preferredStyle: UIAlertController.Style.alert)
            invalidAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(invalidAlert, animated: true, completion: nil)
        /// If information entered is valid and non-blank, clear out all information
        /// Displays an alert to thank the user
        } else {
            nameTextField.text = ""
            emailTextField.text = ""
            textView.text = ""
            
            let alert = UIAlertController(title: "Thank You!",
                                          message: "Your feedback has been sent!",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    /// For top left Cancel bar button
    /// Dismisses the popup view controller
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /// Sets view controller (self) as TextViewDelegate and TextFieldDelegate
    /// Gives the text view rounded and colored borders
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.textView.delegate = self
        
        self.textView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.cornerRadius = 8
    }
}

extension FeedbackViewController: UITextFieldDelegate, UITextViewDelegate {
    // MARK: TextFieldDelegate and TextViewDelegate Methods
    /// Allows the return button to dismiss the keyboard for text views
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
    }
    
    /// Allows the return button to dismiss the keyboard for text fields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
