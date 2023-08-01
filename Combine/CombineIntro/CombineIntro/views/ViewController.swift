//
//  ViewController.swift
//  CombineIntro
//
//  Created by Anup Dsouza on 26/07/23.
//

import UIKit
import Combine

private class CustomTableViewCell: UITableViewCell {
    
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
    }
    
    @objc private func tappedButton() {
        guard let title = button.title(for: .normal) else {
            fatalError()
        }
        action.send(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 8, y: 8, width: contentView.frame.size.width - 16, height: contentView.frame.size.height - 16)
    }
}

final class ViewController: UIViewController, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    private var observers = [AnyCancellable]()
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        APICaller.shared.fetchCompanies()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    print("call finished")
                case .failure(let error):
                    print("call failed with error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] value in
                self?.models = value
                self?.tableView.reloadData()
            })
            .store(in: &observers)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell else {
            fatalError()
        }
        cell.button.setTitle(models[indexPath.row], for: .normal)
        cell.action.sink { value in
            print("You tapped button in cell: \(value)")
        }
        .store(in: &observers)
        return cell
    }
}

