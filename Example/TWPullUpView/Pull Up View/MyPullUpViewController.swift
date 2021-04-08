//
//  MyPullUpView.swift
//  TWPullUpViewExample
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import TWPullUpView
import UIKit

class MyPullUpViewController: TWPullUpViewController {
    
    private let handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private var dummyModel = [DummyModel]()

    override var option: TWPullUpOption {
        return TWPullUpOption()
    }
    
    override var startPercentFromPoint: TWStickyPoint {
        return .percent(0.6)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<30 {
            let model = DummyModel(title: "\(i) Title", desc: "\(i) Desc")
            dummyModel.append(model)
        }
        setUI()
    }
    
    private func setUI() {
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 30
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(handlerView)
        handlerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        handlerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        handlerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handlerView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        handlerView.layer.cornerRadius = 3
        
        view.addSubview(tableView)
        let top = tableView.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 10)
        top.isActive = true
        top.priority = .defaultLow
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        attachScrollView(tableView)
        
        didChangePoint = { [weak self] point in
            
        }
        
        willMoveToPoint = { [weak self] point in
            
        }
        
        didMoveToPoint = { [weak self] point in
            
        }
        
        percentOfMinToMax = { [weak self] point in
            
        }
    }
    
}

extension MyPullUpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = dummyModel[indexPath.row].title
        return cell
    }
}
