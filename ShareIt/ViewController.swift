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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    var sceneView = ARSCNView()
    var cameraButton = UIButton()
    var drawerView = UIView()
    var collectionView: UICollectionView!
    var textArray: [String] = ["Hello", "Hey", "Hi", "Bonjour", "Hola"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define sizes
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        
        // Set up the scene view's frame
        sceneView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        // Set the session's delegate
        sceneView.session.delegate = self
        
        // Set automatic lighting for the scene
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add the scene to the view
        self.view.addSubview(sceneView)
        
        self.configureGestures()
        self.createCameraButton()
        self.createDrawer()
    }
    
    func configureGestures() {
        // Configure pan gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Define sizes
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Gesture state whilst in the process of panning
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
            // Move drawer with pan gesture
            self.drawerView.frame = CGRect(x: 0, y: Int(gestureRecognizer.view!.frame.size.height), width: Int(screenWidth), height: Int(screenHeight))
            self.collectionView.frame = CGRect(x: 0, y: Int(gestureRecognizer.view!.frame.size.height), width: Int(screenWidth), height: 120)
        } else if gestureRecognizer.state == .ended {
            // Gesture state when the pan process has ended
            // Animates smoothly to the desired end position
            // Check whether the swipe is up or down
            if velocity.y < 0 {
                // Open drawer
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: self.view.bounds.height/2 - 120)
                    self.drawerView.frame.origin.y = CGFloat(screenHeight)
                    self.collectionView.frame.origin.y = CGFloat(screenHeight - 120)
                })
            } else {
                // Close drawer
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: self.view.bounds.height/2)
                    self.drawerView.frame.origin.y = CGFloat(screenHeight)
                    self.collectionView.frame.origin.y = CGFloat(screenHeight)
                })
            }
        }
    }
    
    func createCameraButton() {
        // Define sizes
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        let cameraButtonWidth = 60
        
        // Create the main camera button and add it to the view
        self.cameraButton.frame = CGRect(x: Int(screenWidth/2) - Int(cameraButtonWidth/2), y: Int(screenHeight) - Int(cameraButtonWidth) - 30, width: cameraButtonWidth, height: cameraButtonWidth)
        self.cameraButton.backgroundColor = Colours.offWhite
        self.cameraButton.layer.cornerRadius = CGFloat(cameraButtonWidth/2)
        self.cameraButton.layer.borderColor = Colours.white.cgColor
        self.cameraButton.layer.borderWidth = 4
        self.cameraButton.addTarget(self, action: #selector(self.tappedCameraButton), for: .touchUpInside)
        self.sceneView.addSubview(self.cameraButton)
    }
    
    func createDrawer() {
        // Define sizes
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        
        // Create the drawer and add it to the view just off the screen on the y axis
        self.drawerView.frame = CGRect(x: 0, y: Int(screenHeight), width: Int(screenWidth), height: Int(screenHeight))
        self.drawerView.backgroundColor = Colours.grey
        self.sceneView.addSubview(self.drawerView)
        
        // Create scrollable collectionView for the drawer content
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        layout.itemSize = CGSize(width: 120, height: 60)
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: Int(screenHeight), width: Int(screenWidth), height: 120), collectionViewLayout: layout)
        self.collectionView.contentSize = CGSize(width: screenWidth * 5, height: 120)
        self.collectionView.isScrollEnabled = true
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = Colours.clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(TextCell.self, forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of items in the drawer
        return textArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cells for the collectionView and populate it with data from the array
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCell
        cell.text.setTitle(self.textArray[indexPath.row], for: .normal)
        cell.text.setTitleColor(Colours.white, for: .normal)
        cell.text.backgroundColor = Colours.greyLight
        cell.text.layer.cornerRadius = 10
        cell.text.titleLabel?.textAlignment = .center
        cell.text.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        cell.text.addTarget(self, action: #selector(self.tappedText), for: .touchUpInside)
        return cell
    }
    
    @objc func tappedText(button: UIButton) {
        // Haptic feedback
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        
        // Store text from the tapped button
        let textTapped = button.titleLabel?.text ?? "Hello"
        print(textTapped)
    }
    
    @objc func tappedCameraButton(button: UIButton) {
        // Haptic feedback
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
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
