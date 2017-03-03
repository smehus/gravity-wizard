//
//  LevelCompleteLabel.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class LevelCompleteLabel: SKLabelNode {
    
    static func createLabel(with text: String? = nil) -> SKLabelNode? {
        guard
            let scene = SKScene(fileNamed: String(describing: LevelCompleteLabel.self)),
            let labelNode = scene.childNode(withName: "label") as? SKLabelNode
            else {
                return nil
        }
        
        labelNode.zPosition = 20
        if let text = text {
            labelNode.text = text
        }
        return labelNode
    }
}
