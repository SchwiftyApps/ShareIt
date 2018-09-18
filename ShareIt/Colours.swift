//
//  Colours.swift
//  ShareIt
//
//  Created by Andrew Lees, David Dunn, Kye Maloy, and Shihab Mehboob on 03/08/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

// Struct containing custom colours to be used within the app.
struct Colours {
    static var black = UIColor.black
    static var white = UIColor.white
    static var clear = UIColor.clear
    static var red = UIColor(red: 250/255, green: 10/255, blue: 10/255, alpha: 1)
    static var purpleLight = UIColor(red: 71/255, green: 131/255, blue: 213/255, alpha: 1)
    static var purple = UIColor(red: 91/255, green: 151/255, blue: 233/255, alpha: 1)
    static var offWhite = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    // TO DO: Agree on main app tint colour, for now make it purple
    static var appTintColour = UIColor(red: 91/255, green: 151/255, blue: 233/255, alpha: 1)
}
