//
//  WindStreamLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class WindStreamLayer: SKNode {
    
    private func setupSprites() {
        
    }
}

extension WindStreamLayer: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
    }
}
