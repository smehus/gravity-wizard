//
//  SnakeNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/18/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class SnakeNode: SKSpriteNode {
    
    fileprivate func setup() {
        
    }
}

extension SnakeNode: LifecycleListener {
    func didMoveToScene() {
        setup()
    }
}
