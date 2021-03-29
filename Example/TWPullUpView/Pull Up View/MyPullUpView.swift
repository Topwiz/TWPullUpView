//
//  MyPullUpView.swift
//  TWPullUpViewExample
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import TWPullUpView
import UIKit

struct TWCustomOptions: TWOptionProtocol {
    var animationDuration: Double = 0.3
    var animationDamping: CGFloat = 1
    var animationSpringVelocity: CGFloat = 0.4
    var overMaxHeight: Bool = true
    var underMinHeight: Bool = true
}


class MyPullUpView: TWPullUpView {
    
    private let handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let customOptions: TWOptionProtocol = TWCustomOptions()
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
        
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        for i in 0..<30 {
            let model = DummyModel(title: "\(i) Title", desc: "\(i) Desc")
            dummyModel.append(model)
        }
        setUI()
        setOptions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 30
        
        backgroundColor = UIColor.white
        
        addSubview(handlerView)
        handlerView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        handlerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        handlerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handlerView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        handlerView.layer.cornerRadius = 3
        
        addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    private func setOptions() {
        stickyPoints = [.percent(0.3), .percent(0.6), .max]
        setOption(customOptions)
        addScrollView(tableView)
    }
    
}

extension MyPullUpView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = dummyModel[indexPath.row].title
        return cell
    }
}
