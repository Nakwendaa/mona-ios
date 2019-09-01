//
//  RegisterViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-08-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "RegisterViewController"
        static let signUpTitle = NSLocalizedString("Sign up title", tableName: tableName, bundle: .main, value: "", comment: "")
        static let email = NSLocalizedString("Email", tableName: tableName, bundle: .main, value: "", comment: "")
        static let confirmEmail = NSLocalizedString("Confirm email", tableName: tableName, bundle: .main, value: "", comment: "")
        static let username = NSLocalizedString("Username", tableName: tableName, bundle: .main, value: "", comment: "")
        static let password = NSLocalizedString("Password", tableName: tableName, bundle: .main, value: "", comment: "")
        static let confirmPassword = NSLocalizedString("Confirm password", tableName: tableName, bundle: .main, value: "", comment: "")
        static let signUpButton = NSLocalizedString("Sign up button", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    //MARK: - UI Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalizedStringsForTheViewController()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapScreen))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupLocalizedStringsForTheViewController() {
        titleLabel.text = Strings.signUpTitle
        emailTextField.placeholder = Strings.email
        confirmEmailTextField.placeholder = Strings.confirmEmail
        usernameTextField.placeholder = Strings.username
        passwordTextField.placeholder = Strings.password
        confirmPasswordTextField.placeholder = Strings.confirmPassword
        signUpButton.setTitle(Strings.signUpButton, for: .normal)
    }
    
    @objc func tapScreen() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, username != "" else {
            presentMessage(message: "Le nom d'utilisateur est vide.")
            return
        }
    
        
        guard let firstPassword = passwordTextField.text, let secondPassword = confirmPasswordTextField.text, firstPassword != "", secondPassword != "" else {
            presentMessage(message: "Un des mots de passe est vide.")
            return
        }
        
        if !username.isAlphanumeric {
            presentMessage(message: "Le nom d'utilisateur n'est pas une chaîne alphanumérique. Caractère autorisés: a-zA-Z0-9")
            return
        }
        
        if !firstPassword.isAlphanumeric || !secondPassword.isAlphanumeric {
            presentMessage(message: "Le mot de passe n'est pas une chaîne alphanumérique. Caractère autorisés: a-zA-Z0-9")
            return
        }
        
        if firstPassword != secondPassword {
            presentMessage(message: "Les mots de passes entrés sont différents.")
            return
        }
        
        /*
        MonaAPI.shared.register(username: username, email: <#T##String?#>, password: <#T##String#>, completion: <#T##(Result<MonaAPI.RegisterRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void#>)
        let cfg = ServiceConfig(name: "Testing", base: "http://www-etud.iro.umontreal.ca/~beaurevg/ift3150")
        let service = Service(cfg!)
        
        /*
         let createUserOperation = CreateUserOperation(withUsername: username, withPassword: firstPassword)
         createUserOperation.execute(in: service).then {
         dataManager.saveLogin(login: ["username" : username, "password" : firstPassword])
         self.performSegue(withIdentifier: "showApplication", sender: self)
         }.catch {
         error in
         
         if createUserOperation.error == .usernameAlreadyExists {
         self.presentMessage(message: "Le nom d'utilisateur existe déjà. Veuillez choisir un autre nom d'utilisateur.")
         }
         else {
         log.error("Failed to parse JSON. Error: " + error.localizedDescription)
         }
         }
         */
         */
        
    }
    
    private func presentMessage(message: String) {
        let alertController = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            return
        })
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
