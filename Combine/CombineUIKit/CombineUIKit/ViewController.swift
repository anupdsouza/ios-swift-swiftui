//
//  ViewController.swift
//  CombineUIKit
//
//  Created by Anup D'Souza on 27/07/23.
//

import UIKit
import Combine

extension Notification.Name {
    static let newMessage = Notification.Name("newMessage")
}

private struct Message {
    let content: String
}

class ViewController: UIViewController {

    @IBOutlet weak var allowMessagesSwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @Published var canSendMessages: Bool = false
    private var switchSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProcessingChain()
    }
    
    private func setupProcessingChain() {
        switchSubscriber = $canSendMessages
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: sendButton)
    }

    @IBAction func didSwitch(_ sender: UISwitch) {
        canSendMessages = sender.isOn
        
        let messagePublisher = NotificationCenter.Publisher(center: .default, name: .newMessage)
            .map { notification -> String? in
                return (notification.object as? Message)?.content ?? ""

            }
        let messageSubscriber = Subscribers.Assign(object: messageLabel, keyPath: \.text)
        messagePublisher.subscribe(messageSubscriber)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = Message(content: "Current time is \(Date())")
        NotificationCenter.default.post(name: .newMessage, object: message)
    }
}

