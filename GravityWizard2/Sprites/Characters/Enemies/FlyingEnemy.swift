//
//  FlyingEnemy.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

enum FlyingEnemyTexture {
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

class FlyingEnemy: SKSpriteNode {
    var isHit = false
}
