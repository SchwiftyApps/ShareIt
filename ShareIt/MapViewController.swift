//
//  MapViewController.swift
//  ShareIt
//
//  Created by Shibab Mehboob on 17/09/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit
import KituraKit
import MapKit

class mapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var mapView = MKMapView()
    var locationManager = CLLocationManager()
    var backButton = UIButton()
    let client = KituraKit(baseURL: "http://159.122.181.186:31651")
    var models: [Model] = []
    var customToSend = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        self.backButton.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        self.backButton.backgroundColor = Colours.purple
        self.backButton.layer.cornerRadius = CGFloat(20)
        self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.backButton.setImage(UIImage(named: "cross"), for: .normal)
        self.backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        self.view.addSubview(self.backButton)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
        
        self.fetchServerLocations()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update the user's current location periodically
        let region = MKCoordinateRegionMakeWithDistance(locations.last!.coordinate, 500, 500)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchServerLocations() {
        
        // Test pin when there are no server pins
        //let customPin = MKPointAnnotation()
        //customPin.coordinate = CLLocation(latitude: 51.024042, longitude: -1.399812).coordinate
        //customPin.title = "Test Title"
        //customPin.subtitle = "Test Subtitle"
        //self.mapView.addAnnotation(customPin)
        if let client = client {
            client.get("/sample") { (data: [Model]?, error: Error?) in
                guard let models = data else {
                    if let err = error {
                        print("\(err)")
                    }
                    return
                }
                self.models = models
                for items in models {
                    let ID = items.id
                    let longitude = items.longitude
                    let lattitude = items.lattitude
                    // Place a new pin at the location derived from the server
                    let customPin = MKPointAnnotation()
                    customPin.coordinate = CLLocation(latitude: lattitude, longitude: longitude).coordinate
                    customPin.title = items.text
                    customPin.subtitle = ID
                    self.mapView.addAnnotation(customPin)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = view.annotation as? MKPointAnnotation
        for items in models {
            if items.id == selectedAnnotation?.subtitle {
                self.customToSend = selectedAnnotation?.title ?? "Hello"
                let gotoButton = UIButton()
                gotoButton.frame = CGRect(x: 0, y: self.view.bounds.height - 80, width: self.view.bounds.width, height: 80)
                gotoButton.backgroundColor = Colours.appTintColour
                gotoButton.setTitle("Place object in View", for: .normal)
                gotoButton.titleLabel?.textAlignment = .center
                gotoButton.titleLabel?.textColor = UIColor.white
                gotoButton.addTarget(self, action: #selector(tappedGoTo), for: .touchDown)
                self.view.addSubview(gotoButton)
                
            }
        }
    }
    
    @objc func tappedGoTo() {
        self.dismiss(animated: true, completion: nil)
        let dictToSend = ["object": self.customToSend]
        NotificationCenter.default.post(name: Notification.Name("sendData"), object: nil, userInfo: dictToSend)
    }
}
