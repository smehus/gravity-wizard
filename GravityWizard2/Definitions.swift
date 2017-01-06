//
//  Definitions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import Foundation

enum ProjectileType {
    case arrow
    case gravity
}

enum GravityState {
    case climbing
    case falling
    case ground
    
    var animationKey: String {
        return "GravityAnimation"
    }
}

enum Level: Int {
    case one = 1
    case two
}

enum Direction {
    case left
    case right
    case up
    case down
}

struct Images {
    static let radialGravity = "deathtex1"
    static let arrow = "arrow"
    static let arrowBig = "arrow_big"
    static let spark = "spark"
}

struct Actions {
    static let lightMoveAction = "lightMoveAction"
}

struct PhysicsCategory {
    static let None:                UInt32 = 0
    static let Wizard:              UInt32 = 0x1 << 1 // 01
    static let Ground:              UInt32 = 0x1 << 2 // 010
    static let Rock:                UInt32 = 0x1 << 3 // 0100
    static let Edge:                UInt32 = 0x1 << 4 // 01000
    static let Arrow:               UInt32 = 0x1 << 5
    static let Blood:               UInt32 = 0x1 << 6
    static let RadialGravity:       UInt32 = 0x1 << 7
    static let BreakableFormation:  UInt32 = 0x1 << 8
    static let VikingBodyPart:      UInt32 = 0x1 << 9
    static let GravityProjectile:   UInt32 = 0x1 << 10
    
}

enum CollisionCombination {
    case wizardHitsGround
    case rockHitsWizard
    
    case bloodCollidesWithGround
    
    case gravityProjectileHitsGround
    
    case arrowCollidesWithEdge
    case arrowCollidesWithBreakable
    case arrowCollidesWithGround
    case arrowCollidesWithVikingBodyPart
    case none
}
extension UInt32 {
    func collisionCombination() -> CollisionCombination {
        switch self {
        case PhysicsCategory.Ground | PhysicsCategory.Wizard:
            return .wizardHitsGround
        case PhysicsCategory.Rock | PhysicsCategory.Wizard:
            return .rockHitsWizard
        case PhysicsCategory.Blood | PhysicsCategory.Ground:
            return .bloodCollidesWithGround
        case PhysicsCategory.Arrow | PhysicsCategory.Edge:
            return .arrowCollidesWithEdge
        case PhysicsCategory.Arrow | PhysicsCategory.BreakableFormation :
            return .arrowCollidesWithBreakable
        case PhysicsCategory.Arrow | PhysicsCategory.Ground :
            return .arrowCollidesWithGround
        case PhysicsCategory.Arrow | PhysicsCategory.VikingBodyPart:
            return .arrowCollidesWithVikingBodyPart
        case PhysicsCategory.GravityProjectile | PhysicsCategory.Ground:
            return .gravityProjectileHitsGround
        default: return .none
        }
    }
}
