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

        directionalLight.castsShadow = true
        // we set the the shadowMode to deferred rendering, which means the
        // shadows are drawn to the screen after the objects are.
        directionalLight.shadowMode = .deferred
        directionalLight.shadowColor = UIColor.black.withAlphaComponent(0.6)
        directionalLight.shadowRadius = 5.0

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

    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        // the font size is in scene units (1 meter)
        text.font = UIFont.systemFont(ofSize: 1.0)
        // The flatness is the smoothness of the rounded parts of the font.
        // The subdivision it uses when SceneKit creates line segments to approximate the curve
        // of a letter. Smaller values means more line segments, which means smoother fonts,
        // but at a cost of performance.
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: text)
        textNode.castsShadow = true
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        textNode.castsShadow = true

        // What we do here is take the bounding box of the object,
        // and set the pivot to be the center of the X and Z axis, and the lowest point of the Y axis.
        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        (minVec, maxVec) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(minVec.x + (maxVec.x - minVec.x) / 2, minVec.y, minVec.z + (maxVec.z - minVec.z) / 2)

        return textNode
    }

    func addText(string: String, parent: SCNNode) {
        let textNode = self.createTextNode(string: string)
        textNode.position = SCNVector3Zero
        parent.addChildNode(textNode)
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
