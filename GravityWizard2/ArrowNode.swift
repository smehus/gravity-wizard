//
//  ArrowNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

final class ArrowNode: SKSpriteNode {
    
    struct Physics {
        static let category = PhysicsCategory.arrow
        static let contact = PhysicsCategory.Edge | PhysicsCategory.Ground
        static let collision = PhysicsCategory.Edge | PhysicsCategory.Ground | PhysicsCategory.destructible
        static let field = PhysicsCategory.None
    }
    
    var isInFlight: Bool = false
    
    init() {
        let texture = SKTexture(pixelImageNamed: Images.arrow_small)
        super.init(texture: texture, color: .white,
                   size: texture.size())
        name = "Arrow"
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: texture.size().width/2, height: texture.size().height/2))
        physicsBody?.affectedByGravity = true
        physicsBody?.categoryBitMask = Physics.category
        physicsBody?.contactTestBitMask = Physics.contact
        physicsBody?.collisionBitMask = Physics.collision
        physicsBody?.fieldBitMask = Physics.field
        zPosition = 30
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArrowNode: InFlightTrackable {
    
    func collide() {
        
    }
}
