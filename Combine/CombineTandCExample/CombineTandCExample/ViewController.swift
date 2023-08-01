//
//  ViewController.swift
//  CombineTandCExample
//
//  Created by Anup D'Souza on 30/07/23.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // Define publishers
    @Published var acceptedTerms = false
    @Published var acceptedPrivacy = false
    @Published var name = ""
    
    // Combine publishers into single stream
    private var readyToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($acceptedTerms, $acceptedPrivacy, $name)
            .map { terms, privacy, name in
                return terms && privacy && !name.isEmpty
            }.eraseToAnyPublisher()
    }
    
    // Define subscriber
    private var buttonSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Connnect subscriber to publisher
        buttonSubscriber = readyToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: submitButton)
    }
    
    @IBAction func toggledTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }

    @IBAction func toggledPrivacy(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }

    @IBAction func nameUpdated(_ sender: UITextField) {
        name = sender.text ?? ""
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

