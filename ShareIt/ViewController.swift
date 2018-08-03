//
//  ViewController.swift
//  ShareIt
//
//  Created by Andrew Lees, David Dunn, Kye Maloy, and Shihab Mehboob on 30/07/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var cameraButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.configureGestures()
        self.createCameraButton()
    }
    
    func configureGestures() {
        // Configure pan gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.minimumNumberOfTouches = 1
        self.sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Gesture state whilst in the process of panning
            let translation = gestureRecognizer.translation(in: self.sceneView)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.sceneView)
        } else if gestureRecognizer.state == .ended {
            // Gesture state when the pan process has ended
            // Animates smoothly to the desired end position
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: self.view.bounds.height/2 - 120)
            })
        }
    }
    
    func createCameraButton() {
        // Define sizes
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        let cameraButtonWidth = 60
        
        // Create the main camera button and add it to the view
        self.cameraButton.frame = CGRect(x: Int(screenWidth/2) - Int(cameraButtonWidth/2), y: Int(screenHeight) - Int(cameraButtonWidth) - 30, width: cameraButtonWidth, height: cameraButtonWidth)
        self.cameraButton.backgroundColor = Colours.grey
        self.cameraButton.layer.cornerRadius = CGFloat(cameraButtonWidth/2)
        self.cameraButton.layer.borderColor = Colours.white.cgColor
        self.cameraButton.layer.borderWidth = 4
        self.cameraButton.addTarget(self, action: #selector(self.tappedCameraButton), for: .touchUpInside)
        self.sceneView.addSubview(self.cameraButton)
    }
    
    @objc func tappedCameraButton(button: UIButton) {
        // Camera button tap action
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
