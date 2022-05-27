//
//  SCNVector3+Extensions.swift
//  AR-Playground
//
//  Created by Zoe Schmitt on 5/26/22.
//

import Foundation
import SceneKit

extension SCNVector3 {
    public func distance(receiver: SCNVector3) -> Float {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))

        return distance < 0 ? distance * -1 : distance
    }
}
