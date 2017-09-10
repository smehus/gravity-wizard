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
            var nextPosition: CGPoint
            
            ///
            /// Add Field node & Particle Emitter
            ///
            
            switch lastStreamWasUp {
            case true:
                // Down Stream
                nextPosition = CGPoint(x: streamPosition.x + (parentScene.size.width / 3), y: CGFloat.random(min: parentScene.totalSceneSize.height/2, max: parentScene.totalSceneSize.height))
                addStream(at: nextPosition, upwards: false)
            case false:
                // Up Stream
                nextPosition = CGPoint(x: (streamPosition.x + (parentScene.frame.size.width / 3)), y: CGFloat.random(min: -50, max: parentScene.totalSceneSize.height / 2))
                addStream(at: nextPosition, upwards: true)
            }
            
            ///
            /// Add Enemies between the current stream and the next stream
            ///
            
            addEnemy(between: streamPosition, secondPoint: nextPosition, count: 2)
            
            streamPosition = nextPosition
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
    
    private func addEnemy(between firstPoint: CGPoint, secondPoint: CGPoint, count: Int) {
        
        let diff = (firstPoint.x - secondPoint.x) / 2
        let enemyX = firstPoint.x + diff
        
        for _ in 0..<count {
            let enemyY = CGFloat.random(min: min(firstPoint.y, secondPoint.y), max: max(firstPoint.y, secondPoint.y))
            let point = CGPoint(x: enemyX, y: enemyY)
            
            let sizeMultiplier: CGFloat = 3
            let texture: FlyingEnemyTexture = Bool.random() ? .propeller : .winged
            let sprite = FlyingEnemy(texture: texture.texture, color: .white, size: texture.texture.size() * sizeMultiplier)
            sprite.position = convert(point, to: self)
            
            let body = SKPhysicsBody(texture: texture.texture, size: texture.texture.size() * sizeMultiplier)
            body.categoryBitMask = PhysicsCategory.enemy
            body.contactTestBitMask = PhysicsCategory.arrow
            body.collisionBitMask = PhysicsCategory.arrow | PhysicsCategory.Hero | PhysicsCategory.enemy | PhysicsCategory.Ground
            body.fieldBitMask = PhysicsCategory.heroField
            body.isDynamic = true
            body.affectedByGravity = false
            body.allowsRotation = true
            sprite.physicsBody = body
            
            
            addChild(sprite)
        }
    }
}
