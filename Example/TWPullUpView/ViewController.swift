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

    lazy var pullUpView: MyPullUpView = {
        let view = MyPullUpView()
        view.willMoveToPoint = { point in
            
        }
        
        view.didMoveToPoint = { point in
            
        }
        
        view.didChangePoint = { point in
            
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        pullUpView.addOn(view, initialStickyPoint: .percent(0.3), animated: true)

    }

}
