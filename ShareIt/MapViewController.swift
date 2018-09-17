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
    let client = KituraKit(baseURL: "http://159.122.181.186:32062")
    
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
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
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
            client.get("/sample", identifier: "1") { (data: Model?, error: Error?) in
                let longitude = data?.longitude
                let lattitude = data?.lattitude
                
                // Place a new pin at the location derived from the server
                let customPin = MKPointAnnotation()
                customPin.coordinate = CLLocation(latitude: lattitude ?? 0, longitude: longitude ?? 0).coordinate
                customPin.title = data?.text
                customPin.subtitle = "This item has the ID: \(String(describing: data?.id ?? "0"))"
                self.mapView.addAnnotation(customPin)
            }
        }
    }
    
}
