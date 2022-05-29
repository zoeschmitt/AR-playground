//
//  ViewController.swift
//  AR-Playground
//
//  Created by Zoe Schmitt on 5/23/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var sceneController = HoverScene()
    var didInitializeScene: Bool = false
    /// maps anchors to planes. This gives us an easy way to lookup and modify the corresponding plane.
    var planes = [ARPlaneAnchor: Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // visibly shows feature points and the world origin.
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        if let scene = sceneController.scene {
            sceneView.scene = scene
        }

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // tell ARKit that we want to track planes. 
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.session.currentFrame?.camera {
            didInitializeScene = true

            let transform = camera.transform
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            sceneController.makeUpdateCameraPos(towards: position)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }

    /// create our plane, and then add it as a child node to the node that ARKit created.
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
        print("added plane")
    }

    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }

    /// Grab the first node  (if there are hits), then use our topmost() extension to grab the topmost parent, and check if its a doughnut.
    /// If it is, then we add our animation to it. If we didn’t get any hits from our test, then we do as before, adding a new doughnut in
    /// front of the camera.
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if didInitializeScene, let camera = sceneView.session.currentFrame?.camera {
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation)
            if let node = hitTestResults.first?.node, let scene = sceneController.scene, let doughnut = node.topmost(until: scene.rootNode) as? Doughnut {
                doughnut.animate()
            } else {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                sceneController.addDoughnut(position: position)
            }
        }
    }
    
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
