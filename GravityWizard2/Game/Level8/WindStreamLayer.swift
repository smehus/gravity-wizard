//
//  WindStreamLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class WindStreamLayer: SKNode {
    
    private var parentScene: Level8 {
        return scene as! Level8
    }
    
    private let numberOfStreams: CGFloat = 0
    private let particleFactory = ParticleFactory.sharedFactory
    
    func setupStreams(size: CGSize) {
        var streamPosition: CGPoint = CGPoint(x: parentScene.frame.size.width / 3, y: 0)
        let emitter = particleFactory.upwardsWind()
        emitter.position = convert(streamPosition, to: self)
        emitter.zPosition = 50
        addChild(emitter)
        
        while streamPosition.x < (size.width - (parentScene.size.halfWidth)) {
            
        }
    }
}
