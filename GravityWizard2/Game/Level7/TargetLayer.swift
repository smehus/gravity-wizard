//
//  TargetLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Texture {
    case propeller
    case winged
    
    var texture: SKTexture {
        switch self {
        case .propeller:
            return SKTexture(image: #imageLiteral(resourceName: "propeller-enemy-0"))
        case .winged:
            return SKTexture(image: #imageLiteral(resourceName: "winged-enemy-0"))
        }
    }
    
    var animationTextures: [SKTexture] {
        switch self {
        case .propeller:
            return propellerTextures
        case .winged:
            return wingedTextures
        }
    }
    
    private var wingedTextures: [SKTexture] {
        var textures: [SKTexture] = []
        let base = "winged-enemy-"
        for i in 0...4 {
            let t = SKTexture(imageNamed: "\(base)\(i)")
            textures.append(t)
        }
        
        return textures
    }
    
    private var propellerTextures: [SKTexture] {
        var textures: [SKTexture] = []
        let base = "propeller-enemy-"
        for i in 0...5 {
            let t = SKTexture(imageNamed: "\(base)\(i)")
            textures.append(t)
        }
        
        return textures
    }
}

class TargetLayer: SKNode {
    
    var waitDuration: TimeInterval = Double(CGFloat.random(min: 0.0, max: 3.0))
    private var timer: TimeInterval = 0
    
    func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        timer += delta
        
        if timer >= waitDuration {
            timer = 0
            waitDuration = Double(CGFloat.random(min: 0.0, max: 3.0))
            
            triggerEnemy()
        }
    }
    
    private func triggerEnemy() {
        let nextTexture: Texture = Bool.random() ? Texture.propeller : Texture.winged
    }
}

extension TargetLayer: LifecycleListener {
    func didMoveToScene() {
        
    }
}
