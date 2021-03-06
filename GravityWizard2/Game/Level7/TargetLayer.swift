//
//  TargetLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class TargetLayer: SKNode {
    
    static let ENEMY_NAME = "flying-enemy"
    
    var waitDuration: TimeInterval = Double(CGFloat.random(min: 0.0, max: 3.0))
    private var timer: TimeInterval = 0
    
    var parentScene: Level7 {
        return parent as! Level7
    }
    
    func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        timer += delta
        
        if timer >= waitDuration {
            timer = 0
            waitDuration = Double(CGFloat.random(min: 0.0, max: 3.0))
            
            triggerEnemy()
        }
        
        killOffscreenSprites()
    }
    
    private func killOffscreenSprites() {
        enumerateChildNodes(withName: TargetLayer.ENEMY_NAME) { (node, stop) in
            let minY = self.parentScene.camera!.position.y - (self.parentScene.playableHeight / 2)
            if node.position.y < (minY - 100) {
                node.removeFromParent()
            }
        }
    }
    
    private func triggerEnemy() {
        let sizeMultiplier: CGFloat = 3
        let nextTexture: FlyingEnemyTexture = Bool.random() ? .propeller : .winged
        let sprite = FlyingEnemy(texture: nextTexture.texture, color: .white, size: nextTexture.texture.size() * sizeMultiplier)
        sprite.name = TargetLayer.ENEMY_NAME
        let body = SKPhysicsBody(texture: nextTexture.texture, size: nextTexture.texture.size() * sizeMultiplier)
        body.categoryBitMask = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.arrow
        body.collisionBitMask = PhysicsCategory.arrow | PhysicsCategory.Hero | PhysicsCategory.enemy | PhysicsCategory.Ground
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = true
        sprite.physicsBody = body
        
        let xPOS = CGFloat.random(min: 0, max: parentScene.totalSceneSize.width)
        sprite.position = CGPoint(x: xPOS, y: (parentScene.camera!.position.y - (parentScene.playableHeight / 2)))
        sprite.zPosition = 20
        addChild(sprite)
        sprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1500))
        
        let animationAction = SKAction.animate(with: nextTexture.animationTextures, timePerFrame: 0.1)
        sprite.run(SKAction.repeatForever(animationAction))
    }
}

extension TargetLayer: LifecycleListener {
    func didMoveToScene() {
        
    }
}
