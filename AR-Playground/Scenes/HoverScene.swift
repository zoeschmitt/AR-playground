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

        let doughnut = Doughnut()
        doughnut.position = position

        let prevScale = doughnut.scale
        doughnut.scale = SCNVector3(1.0, 1.0, 1.0)
        let scaleAction = SCNAction.scale(to: CGFloat(prevScale.x), duration: 1.5)
        scaleAction.timingMode = .linear

        scaleAction.timingFunction = { (p: Float) in
            return self.easeOutElastic(p)
        }

        scene.rootNode.addChildNode(doughnut)
        doughnut.runAction(scaleAction, forKey: "scaleAction")
    }

    func easeOutElastic(_ t: Float) -> Float {
        let p: Float = 0.3
        let result = pow(2.0, -10.0 * t) * sin((t - p / 4.0) * (2.0 * Float.pi) / p) + 1.0
        return result
    }

    func makeUpdateCameraPos(towards: SCNVector3) {
        guard let scene = self.scene else { return }
        scene.rootNode.enumerateChildNodes({ (node, _) in
            if let doughnut = node.topmost(until: scene.rootNode) as? Doughnut {
                doughnut.move(targetPos: towards)
            }
        })
    }
}
