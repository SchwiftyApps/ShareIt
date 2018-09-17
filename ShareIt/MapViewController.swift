//
//  MapViewController.swift
//  ShareIt
//
//  Created by Shibab Mehboob on 17/09/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class mapViewController: UIViewController {
    
    var mapView = MKMapView()
    var backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view.addSubview(self.mapView)
        
        self.backButton.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        self.backButton.backgroundColor = Colours.purple
        self.backButton.layer.cornerRadius = CGFloat(20)
        self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.backButton.setImage(UIImage(named: "cross"), for: .normal)
        self.backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        self.view.addSubview(self.backButton)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
