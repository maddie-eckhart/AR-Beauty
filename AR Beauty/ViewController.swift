//
//  ViewController.swift
//  AR Beauty
//
//  Created by Madeline Eckhart on 6/20/18.
//  Copyright © 2018 MaddGaming. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet var sceneView: ARSCNView!
    
    var skin: UIImage?
    var nodeModel: SCNNode?
    var shapeToAdd: Int = 1
    
    // Sizing slider
    var newSize:Float = 0.15
    @IBOutlet weak var slValue: UISlider!
    @IBAction func slSize(_ sender: Any) {
        newSize = slValue.value
        viewDidLoad()
    }
    
    // Animate switch
    var animate:Bool = false
    @IBOutlet weak var swValue: UISwitch!
    @IBAction func swAnimate(_ sender: Any) {
        animate = swValue.isOn
        viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        
        // Start the view's AR session with a configuration that uses the rear camera,device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        
        // Turning off session update
        sessionInfoView.isHidden = true
        sessionInfoLabel.isHidden = true
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        addTapGestureToSceneView()
        configureLighting()
        
//        switch shapeToAdd {
//        case 1:
//            addBox()
//        case 2:
//            addGlobe()
//        default:
//            return
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func loadShape(newSkin: UIImage, shape: Int) {
        skin = newSkin
        switch shape {
        case 1:
            shapeToAdd = 1
        case 2:
            shapeToAdd = 2
        default:
            return
        }
    }
    
    func addFromBlender() {
        // Set the view’s delegate
        sceneView.delegate = self
        
        // Create a new scene
        if let modelScene = SCNScene(named:"cylinder.scn") {
            self.nodeModel =  modelScene.rootNode.childNode(withName: "cylinder", recursively: true)
        }
        else {
            print("can't load model in func")
        }

    }
    
    func addGlobe() {
        // Set the view’s delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        let globe = SCNSphere(radius: CGFloat(newSize))
        
        //applying texture
        let material = SCNMaterial()
        material.diffuse.contents = skin
        globe.materials = [material]
        
        let globeNode = SCNNode(geometry: globe)
        globeNode.position = SCNVector3(0,0,-0.5)
        scene.rootNode.addChildNode(globeNode)
        sceneView.scene = scene
        addAnimation(node: globeNode)
        
    }
    
    func addBox() {
        // Set the view’s delegate
        sceneView.delegate = self

        // Create a new scene
        let scene = SCNScene()
        let box = SCNBox(width: CGFloat(newSize), height: CGFloat(newSize), length: CGFloat(newSize), chamferRadius: 0)

        //applying texture
        let material1 = SCNMaterial()
        let skin1 = UIImage(named: "front")
        material1.diffuse.contents = skin1
        let material2 = SCNMaterial()
        let skin2 = UIImage(named: "side1")
        material2.diffuse.contents = skin2
        let material3 = SCNMaterial()
        let skin3 = UIImage(named: "back")
        material3.diffuse.contents = skin3
        let material4 = SCNMaterial()
        let skin4 = UIImage(named: "side2")
        material4.diffuse.contents = skin4
        let material5 = SCNMaterial()
        let skin5 = UIImage(named: "top")
        material5.diffuse.contents = skin5
        let material6 = SCNMaterial()
        let skin6 = UIImage(named: "bottom")
        material6.diffuse.contents = skin6
        box.materials = [material1, material2, material3, material4, material5, material6]

        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,-0.5)
        scene.rootNode.addChildNode(boxNode)

        // Set the scene to the view
        sceneView.scene = scene
        addAnimation(node: boxNode)

    }

    func addAnimation(node: SCNNode) {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 5.0)
        let repeatForever = SCNAction.repeatForever(rotateOne)
        let stop = SCNAction.rotateBy(x: 0, y: 0, z: 0, duration: 0)
        if animate == true {
            node.runAction(repeatForever)
        }else{
            node.runAction(stop)
        }
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    } 
    
    // adding object to plane
    @objc func addProductToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer)
    {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlane)
        
        guard let hitTestResult = hitTestResults.first else {return}
        let transpose = hitTestResult.worldTransform.columns
        let x = transpose.3.x
        let y = transpose.3.y
        let z = transpose.3.z
        
        if let modelScene = SCNScene(named: "cylinder.scn") {
            let modelNode = modelScene.rootNode.childNode(withName: "cylinder", recursively: true)
            modelNode?.position = SCNVector3(x, y, z)
            sceneView.scene.rootNode.addChildNode(modelNode!)
        }else{
            print("cant add")
        }
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addProductToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Product Collection View
    var products: [ProductList] = []
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // list of products
        let cube: ProductList = ProductList(newName: "box", newType: 1, newImage: UIImage(named: "front")!)
        let globe: ProductList = ProductList(newName: "globe", newType: 2, newImage: UIImage(named: "earth")!)
        //let cylinder: ProductList = ProductList(newName: "cylinder", newType: 3, newImage: UIImage(named: "front")!)
        products.append(cube)
        products.append(globe)
        //products.append(cylinder)
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProductCollectionViewCell
        let image = products[indexPath.row].image
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadShape(newSkin: products[indexPath.row].image, shape: products[indexPath.row].type)
        viewDidLoad()
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
////////////////////////////////////////////////////////////////// DETECTING PLANES AND UPDATING AR SESSION LABEL
    // MARK: - ARSCNViewDelegate
    
    // PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
        // adding color to plane
        plane.materials.first?.diffuse.contents = UIColor.purple
        planeNode.opacity = 0.25
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        planeNode.eulerAngles.x = -.pi / 2

        // Add the plane visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.addChildNode(planeNode)
        
    }
 
    // UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
    }
    
    // MARK: - ARSessionDelegate
    /*
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    */
    
    


}
