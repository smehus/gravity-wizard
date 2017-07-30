//
//  Field.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

enum Field {
    case linear
    case turbulence
    case radial
    case velocity
    
    func generate() -> SKFieldNode {
        switch self {
        case .linear:
            return linearField()
        case .radial:
            return radialField()
        case .turbulence:
            return turbulenceField()
        case .velocity:
            return velocityField()
        }
    }
    
    private func turbulenceField() -> SKFieldNode {
        let field = SKFieldNode.turbulenceField(withSmoothness: 1.0, animationSpeed: 5)
        field.strength = 10.0
        return field
    }
    
    private func radialField() -> SKFieldNode {
        let field = SKFieldNode.radialGravityField()
        field.strength = 100.0
        field.falloff = 1.0
        field.isEnabled = true
        return field
    }
    
    private func linearField() -> SKFieldNode {
        let field = SKFieldNode.linearGravityField(withVector: vector_float3(-1, 0, 0))
        field.strength = 9.8
        return field
    }
    
    private func velocityField() -> SKFieldNode {
        let field = SKFieldNode.velocityField(withVector: vector_float3(-1, 0, 0))
        field.zPosition = 20
        return field
    }
}
