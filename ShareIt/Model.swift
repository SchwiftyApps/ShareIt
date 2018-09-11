//
//  Model.swift
//  ShareIt
//
//  Created by Shibab Mehboob on 11/09/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

struct Model: Codable {
    var id: String
    var text: String
    var lattitude: Double
    var longitude: Double
    
    init?(id: String, text: String, lattitude: Double, longitude: Double) {
        // Initialize stored properties.
        self.id = id
        self.text = text
        self.lattitude = lattitude
        self.longitude = longitude
    }
}
