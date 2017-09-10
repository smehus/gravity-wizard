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
    private var lastStreamWasUp: Bool = true
    
    func setupStreams(size: CGSize) {
        var streamPosition: CGPoint = CGPoint(x: parentScene.frame.size.width / 3, y: 0)
        addStream(at: streamPosition)
        
        while streamPosition.x < (size.width - (parentScene.size.halfWidth)) {
            
            switch lastStreamWasUp {
            case true:
                // Down Stream
                streamPosition = CGPoint(x: streamPosition.x + (parentScene.size.width / 3), y: CGFloat.random(min: parentScene.totalSceneSize.height/2, max: parentScene.totalSceneSize.height))
                addStream(at: streamPosition, upwards: false)
            case false:
                // Up Stream
                streamPosition = CGPoint(x: (streamPosition.x + (parentScene.frame.size.width / 3)), y: CGFloat.random(min: -50, max: parentScene.totalSceneSize.height / 2))
                addStream(at: streamPosition, upwards: true)
            }
        }
    }
    
    private func addStream(at point: CGPoint, upwards: Bool = true) {
        lastStreamWasUp = upwards
        let initialEmitter = upwards ? particleFactory.upwardsWind() : particleFactory.downwardsWind()
        initialEmitter.position = convert(point, to: self)
        initialEmitter.zPosition = 50
        addChild(initialEmitter)
        
        let vector = upwards ? vector_float3(0, 1, 0) : vector_float3(0, -1, 0)
        let field = SKFieldNode.linearGravityField(withVector: vector)
        field.position = convert(point, to: self)
        field.categoryBitMask = PhysicsCategory.heroField
        field.strength = 15
        field.region = SKRegion(size: CGSize(width: 300, height: (scene as! GameScene).totalSceneSize.height))
        addChild(field)
    }
}
