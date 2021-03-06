//
//  Plane.swift
//  AR-Playground
//
//  Created by Zoe Schmitt on 5/29/22.
//

import Foundation
import SceneKit
import ARKit

class Plane: SCNNode {
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    var planeNode: SCNNode

    var shadowPlaneGeometry: SCNPlane
    var shadowNode: SCNNode

    init(_ anchor: ARPlaneAnchor) {
        // Save the anchor that we belong to
        self.planeAnchor = anchor
        // Load up our grid image that we’ll use as the texture
        let grid = UIImage(named: "plane_grid.png")
        // Create the plane geometry
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        // Apply the texture
        let material = SCNMaterial()
        material.diffuse.contents = grid
        self.planeGeometry.materials = [material]
        self.planeGeometry.firstMaterial?.transparency = 0.5
        self.planeNode = SCNNode(geometry: planeGeometry)
        // Position the node. We position the node slightly underneath the origin, so that if we add objects at a Y value of 0 the plane won’t interfere with the visuals of the new object.
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.planeNode.castsShadow = false

        self.shadowPlaneGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = UIColor.white
        shadowMaterial.lightingModel = .constant
        shadowMaterial.writesToDepthBuffer = true
        shadowMaterial.colorBufferWriteMask = []
        self.shadowPlaneGeometry.materials = [shadowMaterial]

        self.shadowNode = SCNNode(geometry: shadowPlaneGeometry)
        self.shadowNode.transform = planeNode.transform
        // we don’t want that plane to be casting its own shadows
        self.shadowNode.castsShadow = false

        super.init()

        self.addChildNode(planeNode)
        self.addChildNode(shadowNode)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.extent.x, -0.002, anchor.center.z)
    }

    func setPlaneVisibility(_ visible: Bool) {
        self.planeNode.isHidden = !visible
    }
}
