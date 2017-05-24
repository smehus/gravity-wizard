//
//  RotarySlider.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/24/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let rotary = "rotary"
    static let anchor = "anchor"
}

fileprivate struct Physics {
    
}

final class RotarySlider: SKNode {
    
    fileprivate var rotary: SKSpriteNode?
    fileprivate var anchor: SKSpriteNode?
    
    fileprivate func resolveNodes() {
        guard
            let rotaryNode = childNode(withName: Names.rotary) as? SKSpriteNode,
            let anchorNode = childNode(withName: Names.anchor) as? SKSpriteNode
        else {
                assertionFailure("Rotary Slider failed to resolve sprites")
                return
        }
        
        rotary = rotaryNode
        anchor = anchorNode
        
        attachPhysics()
    }

    fileprivate func attachPhysics() {
        
    }
}

extension RotarySlider: LifecycleListener {
    func didMoveToScene() {
        resolveNodes()
    }
}
