//
//  Plane.swift
//  ShareIt
//
//  Created by Shibab Mehboob on 09/08/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    var shadowPlaneGeometry: SCNPlane
    var shadowNode: SCNNode
    
    init(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = SCNMaterial()
        self.planeGeometry.materials = [material]
        self.planeGeometry.firstMaterial?.transparency = 0
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        // Add shadow to the plane
        self.shadowPlaneGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = UIColor.white
        shadowMaterial.lightingModel = .constant
        shadowMaterial.writesToDepthBuffer = true
        shadowMaterial.colorBufferWriteMask = []
        self.shadowPlaneGeometry.materials = [shadowMaterial]
        self.shadowNode = SCNNode(geometry: shadowPlaneGeometry)
        self.shadowNode.transform = planeNode.transform
        // Prevent the actual plane and node from casting a shadow
        self.shadowNode.castsShadow = false
        
        super.init()
        
        // Add the node to the scene
        self.addChildNode(planeNode)
        
        // Add the shadow node to the scene
        self.addChildNode(shadowNode)
        
        // Placed 2 mm below the plane's origin
        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        // Update the plane when something changes
        self.planeAnchor = anchor
        // Make the plane as wide and deep as possible
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        // Placed 2 mm below the plane's origin
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
    }

}
