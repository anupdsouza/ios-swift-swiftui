//
//  ViewController.swift
//  CombineWizardSchoolExample
//
//  Created by Anup D'Souza on 30/07/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var repeatPasswordTxtField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    // 1. Define publishers
    @Published var username = ""
    @Published var password = ""
    @Published var repeatPassword = ""
    
    // 2. Define validation as publishers
    var validatedUsername: AnyPublisher<String?, Never> {
        return $username // not using CombineLatest since its a single publisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { username in
                return Future { promise in
                    self.usernameAvailable(username) { available in
                        promise(.success(available ? username : nil))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    var validatedPasswords: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $repeatPassword) // using CombineLatest for 2 publishers
            .map { pwd, repeatPwd in
                return (!pwd.isEmpty && !repeatPwd.isEmpty && (pwd == repeatPwd)) ? pwd : nil
            }
            .map {
                $0 == "password123" ? nil : $0
            }
            .eraseToAnyPublisher()
    }

    // 3. Combine publishers into single stream
    var validateCredentials: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validatedUsername, validatedPasswords)
            .receive(on: RunLoop.main)
            .map { uname, pwd in
                guard let uname = uname, let pwd = pwd else {
                    return nil
                }
                return (uname, pwd)
            }
            .eraseToAnyPublisher()
    }
    
    // 4. Define subscriber
    private var buttonSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    private func setup() {
        // 5. Create subscriber
        buttonSubscriber = validateCredentials
            .receive(on: RunLoop.main)
            .map{ $0 != nil } // Validate the string tuple returned from validateCredentials for enabling/disabling submit button
            .assign(to: \.isEnabled, on: submitButton)
    }
    
    private func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            completion(!username.isEmpty) // fake asynchronously executing method that queries backend for availability of chosen username
        })
    }
    
    @IBAction func nameUpdated(_ sender: UITextField) {
        username = sender.text ?? ""
    }
    
    @IBAction func passwordUpdated(_ sender: UITextField) {
        password = sender.text ?? ""
    }
    
    @IBAction func repeatPasswordUpdated(_ sender: UITextField) {
        repeatPassword = sender.text ?? ""
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

