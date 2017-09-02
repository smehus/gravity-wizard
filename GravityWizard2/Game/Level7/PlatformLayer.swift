//
//  PlatformLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum SpawnState {
    case generation
    case done
}

class PlatformLayer: SKNode {
    
    private var state: SpawnState = .generation
    private var platformTexture: SKTexture?
    private var lastPlatformPosition: CGPoint?
    
    private var randomXPosition: CGFloat {
        return CGFloat.random(min: 0, max: parentScene.totalSceneSize.width)
    }
    
    private var parentScene: Level7 {
        return scene as! Level7
    }
    
    func setupSprites() {
        platformTexture = SKTexture(image: #imageLiteral(resourceName: "grass-edge-platform"))
    }
    
    func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        if state == .generation {
            spawnPlatform()
        }
    }
    
    private func spawnPlatform() {
        switch lastPlatformPosition {
        case .none:
            spawnInitial()
        case .some(let pos):
            spawnNext(position: pos)
        }
    }
    
    private func spawnInitial() {
        guard let texture = platformTexture else { return }
        
        let sprite = SKSpriteNode(texture: texture)
        let body = SKPhysicsBody(texture: texture, size: texture.size())
        body.categoryBitMask = PhysicsCategory.Ground
        body.collisionBitMask = PhysicsCategory.Hero
        body.contactTestBitMask = PhysicsCategory.Hero
        body.isDynamic = false
        
        sprite.physicsBody = body
        sprite.position = CGPoint(x: randomXPosition, y: parentScene.playableHeight / 2)
        addChild(sprite)
        
        lastPlatformPosition = sprite.position
    }
    
    private func spawnNext(position: CGPoint) {
        
    }
}

extension PlatformLayer: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
    }
}
