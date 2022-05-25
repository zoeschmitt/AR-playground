//
//  HoverScene.swift
//  AR-Playground
//
//  Created by Zoe Schmitt on 5/24/22.
//

import Foundation
import SceneKit

struct HoverScene {

    var scene: SCNScene?

    init() {
        scene = self.initializeScene()
    }

    func initializeScene() -> SCNScene? {
        let scene = SCNScene()

        setDefaults(scene: scene)

        return scene
    }

    func setDefaults(scene: SCNScene) {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)

        // Create a directional light with an angle to provide a more interesting look
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.color = UIColor(white: 0.8, alpha: 1.0)
        let directionalNode = SCNNode()
        directionalNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-40), GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(0))
        directionalNode.light = directionalLight
        scene.rootNode.addChildNode(directionalNode)
    }

    func addDoughnut(position: SCNVector3) {
        guard let scene = self.scene else { return }

        let containerNode = SCNNode()

        let nodesInFile = SCNNode.allNodes(from: "doughnut.dae")
        print(nodesInFile)
        nodesInFile.forEach { (node) in
            containerNode.addChildNode(node)
        }
        containerNode.position = position
        scene.rootNode.addChildNode(containerNode)
    }
}
