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
    
    // ARKit variables
    var textNode = SCNNode()
    var planes = [ARPlaneAnchor: Plane]()
    var sceneView = ARSCNView()
    
    // UI variables
    var cameraButton = UIButton()
    var cameraBackground = UIView()
    var cameraLeftButton = UIButton()
    var cameraRightButton = UIButton()
    var drawerView = UIView()
    var overlayView = UIButton()
    var upIndicator = UIImageView()
    var collectionView: UICollectionView!
    let feedback = UISelectionFeedbackGenerator()
    let feedbackSuccess = UINotificationFeedbackGenerator()
    var textArray: [String] = ["Kitura", "Swift", "Hello", "Hey", "Hi", "Hola", "Hëllo", "Hêy", "Hī", "Høla", "Hęllo", "Hėy", "Hì", "Hœla"]
    
    public struct screenSize {
        static var width: CGFloat = UIViewController().view.bounds.width
        static var height: CGFloat = UIViewController().view.bounds.height
    }
    
    override var prefersStatusBarHidden: Bool {
        // Status bar should ideally be hidden in an AR experience
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the scene view's frame
        sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
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
        
        // Set up the overlay view
        overlayView.frame = CGRect(x: 0, y: 0, width: Int(screenSize.width), height: Int(screenSize.height) - Int(120))
        overlayView.backgroundColor = Colours.black.withAlphaComponent(0.01)
        overlayView.addTarget(self, action: #selector(self.tappedDismissOverlay), for: .touchUpInside)
        overlayView.alpha = 0
        
        // Add the scene to the view
        self.view.addSubview(sceneView)
        self.view.addSubview(overlayView)
        
        self.createCameraButton()
        self.configureGestures()
        self.createDrawer()
    }
    
    func configureGestures() {
        // Configure pan gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
        
        // Configure camera long-hold gesture for extra actions
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGestureRecognizer.minimumPressDuration = 0.4
        self.cameraButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .began) {
            // Gesture state when long-hold began
            feedback.selectionChanged()
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                self.cameraButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                self.cameraBackground.alpha = 1
                self.cameraLeftButton.alpha = 1
                self.cameraRightButton.alpha = 1
                self.overlayView.alpha = 1
                self.upIndicator.alpha = 0
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocity(in: self.view)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Gesture state whilst in the process of panning
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
            // Move drawer with pan gesture
            self.drawerView.frame = CGRect(x: 0, y: Int(gestureRecognizer.view!.frame.size.height), width: Int(screenSize.width), height: Int(screenSize.height))
            self.collectionView.frame = CGRect(x: 0, y: Int(gestureRecognizer.view!.frame.size.height), width: Int(screenSize.width), height: 120)
        } else if gestureRecognizer.state == .ended {
            // Gesture state when the pan process has ended
            // Animates smoothly to the desired end position
            // Check whether the swipe is up or down
            if velocity.y < 0 {
                // Open drawer
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: self.view.bounds.height/2 - 120)
                    self.drawerView.frame.origin.y = CGFloat(screenSize.height)
                    self.collectionView.frame.origin.y = CGFloat(screenSize.height - 120)
                    self.cameraButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                    self.cameraButton.backgroundColor = Colours.grey.withAlphaComponent(0.5)
                    self.cameraButton.layer.borderColor = Colours.white.withAlphaComponent(0.3).cgColor
                    self.overlayView.alpha = 1
                    self.upIndicator.alpha = 0
                })
            } else {
                // Close drawer
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: self.view.bounds.height/2)
                    self.drawerView.frame.origin.y = CGFloat(screenSize.height)
                    self.collectionView.frame.origin.y = CGFloat(screenSize.height)
                    self.cameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.cameraButton.backgroundColor = Colours.offWhite
                    self.cameraButton.layer.borderColor = Colours.white.cgColor
                    self.overlayView.alpha = 0
                    self.upIndicator.alpha = 0.65
                })
            }
        }
    }
    
    func createCameraButton() {
        // TO DO: Consider replacing the icons below with better quality icons
        
        // Create camera background for when the camera button is long-pressed
        self.cameraBackground.frame = CGRect(x: Int(screenSize.width/2) - Int(146), y: Int(screenSize.height) - Int(60) - 62, width: 292, height: 84)
        self.cameraBackground.backgroundColor = Colours.grey.withAlphaComponent(0.8)
        self.cameraBackground.layer.cornerRadius = CGFloat(42)
        self.cameraBackground.alpha = 0
        self.sceneView.addSubview(self.cameraBackground)
        
        // Create camera left button for when the camera button is long-pressed
        self.cameraLeftButton.frame = CGRect(x: Int(screenSize.width/2) - Int(120), y: Int(screenSize.height) - Int(60) - 40, width: 40, height: 40)
        self.cameraLeftButton.backgroundColor = Colours.clear
        self.cameraLeftButton.layer.cornerRadius = CGFloat(32)
        self.cameraLeftButton.alpha = 0
        self.cameraLeftButton.addTarget(self, action: #selector(self.tappedCameraLeftButton), for: .touchUpInside)
        self.cameraLeftButton.setImage(UIImage(named: "cross"), for: .normal)
        self.sceneView.addSubview(self.cameraLeftButton)
        
        // Create camera right button for when the camera button is long-pressed
        self.cameraRightButton.frame = CGRect(x: Int(screenSize.width/2) + Int(78), y: Int(screenSize.height) - Int(60) - 40, width: 40, height: 40)
        self.cameraRightButton.backgroundColor = Colours.clear
        self.cameraRightButton.layer.cornerRadius = CGFloat(32)
        self.cameraRightButton.alpha = 0
        self.cameraRightButton.addTarget(self, action: #selector(self.tappedCameraRightButton), for: .touchUpInside)
        self.cameraRightButton.setImage(UIImage(named: "right"), for: .normal)
        self.sceneView.addSubview(self.cameraRightButton)
        
        // Create the main camera button and add it to the view
        self.cameraButton.frame = CGRect(x: Int(screenSize.width/2) - Int(60/2), y: Int(screenSize.height) - Int(60) - 50, width: 60, height: 60)
        self.cameraButton.backgroundColor = Colours.offWhite
        self.cameraButton.layer.cornerRadius = CGFloat(60/2)
        self.cameraButton.layer.borderColor = Colours.white.cgColor
        self.cameraButton.layer.borderWidth = 4
        self.cameraButton.addTarget(self, action: #selector(self.tappedCameraButton), for: .touchUpInside)
        self.sceneView.addSubview(self.cameraButton)
        
        // Create the swipe up prompt indicator
        self.upIndicator.frame = CGRect(x: Int(screenSize.width/2) - Int(20), y: Int(screenSize.height) - Int(40), width: 40, height: 37)
        self.upIndicator.backgroundColor = Colours.clear
        self.upIndicator.alpha = 0.65
        self.upIndicator.image = UIImage(named: "upArrow")
        self.sceneView.addSubview(self.upIndicator)
    }
    
    func createDrawer() {
        // Create the drawer and add it to the view just off the screen on the y axis
        self.drawerView.frame = CGRect(x: 0, y: Int(screenSize.height), width: Int(screenSize.width), height: Int(screenSize.height))
        self.drawerView.backgroundColor = Colours.grey
        self.sceneView.addSubview(self.drawerView)
        
        // Create scrollable collectionView for the drawer content
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        layout.itemSize = CGSize(width: 120, height: 60)
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: Int(screenSize.height), width: Int(screenSize.width), height: 120), collectionViewLayout: layout)
        self.collectionView.contentSize = CGSize(width: screenSize.width * 5, height: 120)
        self.collectionView.isScrollEnabled = true
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
    
    @objc func tappedDismissOverlay(button: UIButton) {
        // Handle any button related functionality here
        self.tapDismiss()
    }
    
    func tapDismiss() {
        // Close drawer
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            self.drawerView.frame.origin.y = CGFloat(screenSize.height)
            self.collectionView.frame.origin.y = CGFloat(screenSize.height)
            self.cameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.cameraButton.backgroundColor = Colours.offWhite
            self.cameraButton.layer.borderColor = Colours.white.cgColor
            self.overlayView.alpha = 0
            self.upIndicator.alpha = 0.65
        })
        
        // Dismiss camera background
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            self.cameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.cameraBackground.alpha = 0
            self.cameraLeftButton.alpha = 0
            self.cameraRightButton.alpha = 0
        })
    }
    
    @objc func tappedCameraLeftButton(button: UIButton) {
        // Haptic feedback
        feedback.selectionChanged()
        
        // Remove all nodes and models from the AR scene
        self.tapDismiss()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        // Display alert showing that the AR objects have been deleted
        self.createAlertBanner(text: "Removed all ARKit text objects", width: 300, yPos: Int(screenSize.height) - Int(195))
    }
    
    @objc func tappedCameraRightButton(button: UIButton) {
        // Haptic feedback
        feedback.selectionChanged()
        
        // Send off placed objects to the Kitura server
        self.tapDismiss()
        
        // TO DO: Logic for sending off AR objects to the server
        
        // Display alert showing success once the AR objects have been uploaded
        self.createAlertBanner(text: "Successfully uploaded to server", width: 300, yPos: Int(screenSize.height) - Int(195))
    }
    
    func createAlertBanner(text: String, width: CGFloat, yPos: Int) {
        let banner = UIButton()
        banner.frame = CGRect(x: Int(screenSize.width/2) - Int(width/2), y: Int(yPos), width: Int(width), height: 40)
        banner.layer.cornerRadius = 20
        banner.backgroundColor = Colours.appTintColour
        banner.setTitle(text, for: .normal)
        banner.setTitleColor(Colours.white, for: .normal)
        banner.titleLabel?.textColor = Colours.white
        banner.alpha = 0
        self.view.addSubview(banner)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            banner.alpha = 1
            self.feedbackSuccess.notificationOccurred(.success)
        })
        
        UIView.animate(withDuration: 0.5, delay: 2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            banner.alpha = 0
        })
    }
    
    @objc func tappedCameraButton(button: UIButton) {
        // Haptic feedback
        feedback.selectionChanged()
        
        // Place the floating AR object in the view
        if let plane = SCNNode() as? Plane, let planeParent = plane.parent {
            self.placeGreetingText(parentNode: planeParent)
        }
    }
    
    @objc func tappedText(button: UIButton) {
        // Haptic feedback
        feedback.selectionChanged()
        
        // Store text from the tapped button
        let textTapped = button.titleLabel?.text ?? "Hello"
        
        // Close drawer when text is tapped
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            self.drawerView.frame.origin.y = CGFloat(screenSize.height)
            self.collectionView.frame.origin.y = CGFloat(screenSize.height)
            self.cameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.cameraButton.backgroundColor = Colours.offWhite
            self.cameraButton.layer.borderColor = Colours.white.cgColor
        })
        
        // Add selected text to the AR view
        textNode = self.createGreetingTextNode(string: textTapped)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Detect horizontal planes
        configuration.planeDetection = .horizontal

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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            // Add a plane to the view if an anchor point exists
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            // Update the plane when something changes in the view, which ensures that node points are always current
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        // Add a plane to the view based on the anchor point
        let plane = Plane(anchor)
        node.addChildNode(plane)
        planes[anchor] = plane
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        // Update the plane based on any changes
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func createGreetingTextNode(string: String) -> SCNNode {
        // Create a 3D text model based on a passed in String
        let text = SCNText(string: string, extrusionDepth: 0.1)
        // Font size is in scene units (meters)
        text.font = UIFont.systemFont(ofSize: 1.0)
        // Flatness is smoothness of curves and edges (a smaller flatness value looks better, but at the cost of performance)
        text.flatness = 0.008
        
        // TO DO: Add colour picker option for the text model, maybe when it's tapped
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        // Add the model to the scene
        // TO DO: Add pinch gesture and adjust scale value to scale text before dropping in the view
        let textNode = SCNNode(geometry: text)
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        // Set a bounding box to the text model, and place it to the centre of the x and z axis, and to the bottom of the y axis to prevent it floating
        var minVector = SCNVector3Zero
        var maxVector = SCNVector3Zero
        (minVector, maxVector) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(minVector.x + (maxVector.x - minVector.x)/2, minVector.y, minVector.z + (maxVector.z - minVector.z)/2)
        return textNode
    }
    
    func placeGreetingText(parentNode: SCNNode) {
        // Binds a text model to a parent node, dropping it in the AR scene
        textNode.position = SCNVector3Zero
        parentNode.addChildNode(textNode)
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
