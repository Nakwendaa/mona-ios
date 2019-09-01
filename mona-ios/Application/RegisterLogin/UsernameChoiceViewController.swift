//
//  UsernameChoiceViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-08-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class UsernameChoiceViewController: UIViewController {

    //MARK: - Types
    struct Strings {
        private static let tableName = "UsernameChoiceViewController"
        static let hintUsername = NSLocalizedString("Hint username", tableName: tableName, bundle: .main, value: "", comment: "")
        static let username = NSLocalizedString("Username", tableName: tableName, bundle: .main, value: "", comment: "")
        static let valid = NSLocalizedString("Valid", tableName: tableName, bundle: .main, value: "", comment: "")
        static let usernameAlreadyExists = NSLocalizedString("Username already exists", tableName: tableName, bundle: .main, value: "", comment: "")
        static let error = NSLocalizedString("Error", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    struct UsernameTextFieldConfig {
        let backgroundColor: UIColor,
        hintBackgroundColor: UIColor
        var hintText: NSString
        let hintTextColor: UIColor,
        textColor: UIColor
        
    }
    
    // MARK: - Parameters
    let hintUsernameLabelTextColor : UIColor = .lightGray
    let rangeLengthUsername : ClosedRange = 6...16
    var usernameTextFieldConfig = UsernameTextFieldConfig(
        backgroundColor: UIColor(red: CGFloat(242)/255.0, green: CGFloat(242)/255.0, blue: CGFloat(242)/255.0, alpha: 1.0),
        hintBackgroundColor: UIColor(red: CGFloat(206)/255.0, green: CGFloat(214)/255.0, blue: CGFloat(224)/255.0, alpha: 1.0),
        hintText: NSString(string: Strings.username),
        hintTextColor: .darkGray,
        textColor: UIColor(red: CGFloat(47)/255.0, green: CGFloat(53)/255.0, blue: CGFloat(66)/255.0, alpha: 1.0)
    )
    
    //MARK: - UI Properties
    @IBOutlet weak var hintUsernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var validButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func validButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        
        let username = usernameTextField.text!
        let password = "123456"
        
        MonaAPI.shared.register(username: username, email: nil, password: password) { result in
            switch result {
            case .success(let registerResponse):
                let token = registerResponse.token
                log.debug(token)
                UserDefaults.Credentials.set(username, forKey: .username)
                UserDefaults.Credentials.set(password, forKey: .password)
                UserDefaults.Credentials.set(token, forKey: .token)
                DispatchQueue.main.async {
                    self.showApp()
                }
            case .failure(let httpError):
                UIAlertController.presentMessage(from: self, title: Strings.error, message: httpError.errorDescription ?? "No error description", okCompletion: nil, presentCompletion: nil)
            }
        }
    }
    
    private func showApp() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            delegate.window?.rootViewController = tabBarController
            delegate.window?.rootViewController!.view.alpha = 0.0;
            UIView.animate(withDuration: 0.5, animations: {
                delegate.window?.rootViewController!.view.alpha = 1.0
            })
        }
    }
    
    private func setupViewController() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        hintUsernameLabel.text = Strings.hintUsername
        setupUsernameTextField()
        setupValidButton()
    }
    
    
    private func setupUsernameTextField() {
        
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldDidChange(textfield:)), for: .editingChanged)
        usernameTextFieldConfig.hintText = NSString.localizedStringWithFormat(usernameTextFieldConfig.hintText, rangeLengthUsername.lowerBound, rangeLengthUsername.upperBound)
        
        usernameTextField.textColor = usernameTextFieldConfig.hintTextColor
        usernameTextField.text = usernameTextFieldConfig.hintText as String
        usernameTextField.backgroundColor = usernameTextFieldConfig.hintBackgroundColor
    }
    
    private func setupValidButton() {
        validButton.setTitle(Strings.valid, for: .normal)
        validButton.isEnabled = false
    }
    
    @objc private func dismissKeyboard() {
        usernameTextField.endEditing(true)
    }
    
    @objc private func usernameTextFieldDidChange(textfield: UITextField) {
        
        // If username is empty, it is not valid
        guard let username = textfield.text else {
            validButton.isEnabled = false
            return
        }
        
        // Else check the username is alphanumeric and the length range is ok.
        if username.isAlphanumeric && rangeLengthUsername.contains(username.count) {
            validButton.isEnabled = true
        }
        else {
            validButton.isEnabled = false
        }
    }
}

//MARK: - UITextFieldDelegate
extension UsernameChoiceViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if usernameTextField.backgroundColor == usernameTextFieldConfig.hintBackgroundColor &&
            usernameTextField.textColor == usernameTextFieldConfig.hintTextColor {
            usernameTextField.textColor = usernameTextFieldConfig.textColor
            usernameTextField.text = ""
            usernameTextField.backgroundColor = usernameTextFieldConfig.hintBackgroundColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if usernameTextField.text == nil || usernameTextField.text == "" {
            usernameTextField.textColor = usernameTextFieldConfig.hintTextColor
            usernameTextField.text = usernameTextFieldConfig.hintText as String
            usernameTextField.backgroundColor = usernameTextFieldConfig.hintBackgroundColor
        }
    }
}
