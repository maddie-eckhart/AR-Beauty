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
    var skin: UIImage = UIImage(named: "wooden_box.jpg")!
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
        //addFromBlender()

        super.viewDidLoad()
        switch shapeToAdd {
        case 1:
            addBox()
        case 2:
            addGlobe()
        default:
            return
        }

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
        // let scene = SCNScene(named: "Assets.scnassets/cylinder.dae")
        
        let scene = SCNScene(named: "cylinder.scn")!
//        if (scene == nil) {
//            fatalError("Scene not loaded")
//        }
//
//        var playerNode = scene!.rootNode.childNode(withName: "Cylinder", recursively: true)
//        if (playerNode == nil) {
//            fatalError("Ship node not found")
//        }
//
//        playerNode!.scale = SCNVector3(x: 0.25, y: 0.25, z: 0.25)
//
//        scene?.rootNode.addChildNode(playerNode!)
        sceneView.scene = scene

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
        let material = SCNMaterial()
        material.diffuse.contents = skin
        box.materials = [material]

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
    
    // Product Collection View
    var products: [ProductList] = []
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let cube: ProductList = ProductList(newName: "box", newType: 1, newImage: UIImage(named: "wooden_box")!)
        let globe: ProductList = ProductList(newName: "globe", newType: 2, newImage: UIImage(named: "earth")!)
        products.append(cube)
        products.append(globe)
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
    
    /* PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        // Add the plane visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode)
        
    }
 */
 
    /* UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        // Add cube
//        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
//        cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
//
//        sceneView.scene.rootNode.addChildNode(cubeNode)
        
    }
    
    // MARK: - ARSessionDelegate
    
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
