//
//  TextCell.swift
//  ShareIt
//
//  Created by Andrew Lees, David Dunn, Kye Maloy, and Shihab Mehboob on 03/08/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

class TextCell: UICollectionViewCell {
    
    var text = UIButton()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.text.frame.size.width = 120
        self.text.frame.size.height = contentView.frame.height
        contentView.addSubview(self.text)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
