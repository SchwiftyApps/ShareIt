//
//  InfoViewController.swift
//  ShareIt
//
//  Created by Andrew Lees, David Dunn, Kye Maloy, and Shihab Mehboob on 03/08/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    
    var dismissButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's background colour
        self.view.backgroundColor = Colours.white
        
        // Add dismiss button
        self.dismissButton.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        self.dismissButton.backgroundColor = Colours.offWhite
        self.dismissButton.layer.cornerRadius = CGFloat(20)
        self.dismissButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        self.view.addSubview(self.dismissButton)
    }
    
    @objc func dismissView(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
