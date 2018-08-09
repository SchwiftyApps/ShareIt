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
    static var grey = UIColor(red: 40/255, green: 40/255, blue: 50/255, alpha: 1)
    static var greyLight = UIColor(red: 70/255, green: 70/255, blue: 80/255, alpha: 1)
    static var offWhite = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    // TO DO: Agree on main app tint colour
    static var appTintColour = UIColor(red: 30/255, green: 70/255, blue: 150/255, alpha: 1)
}

struct ScreenSize {
    static var width: CGFloat = UIViewController().view.bounds.width
    static var height: CGFloat = UIViewController().view.bounds.height
}
