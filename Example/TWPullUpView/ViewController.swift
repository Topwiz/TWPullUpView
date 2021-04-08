//
//  ViewController.swift
//  TWPullUpViewExample
//
//  Created by Jeehoon Son on 2021/03/29.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    let mapView = MKMapView()

    var pullUpViewController: MyPullUpViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        pullUpViewController = MyPullUpViewController()
        pullUpViewController.stickyPoints = [.percent(0.3), .percent(0.8)]
        pullUpViewController.isPullUpScrollEnabled = true
        pullUpViewController.addOn(self, initialStickyPoint: .percent(0.3), animated: true)

    }
}
