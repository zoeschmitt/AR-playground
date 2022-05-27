//
//  Node+Extensions.swift
//  AR-Playground
//
//  Created by Zoe Schmitt on 5/24/22.
//

import SceneKit

extension SCNNode {

    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }

            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
            objScene.rootNode.enumerateChildNodes({ (node, _) in
                nodesInFile.append(node)
            })
        } catch { }
        return nodesInFile
    }

    /// checks to see if each node returned in the hitTest is a Doughnut. To do that we need to grab the topmost parent node for each node we want to check.
    func topmost(parent: SCNNode? = nil, until: SCNNode) -> SCNNode {
        if let pNode = self.parent {
            return pNode == until ? self : pNode.topmost(parent: pNode, until: until)
        } else {
            return self
        }
    }
}
