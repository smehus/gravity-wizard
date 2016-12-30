//
//  Definitions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import Foundation

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
}

struct Actions {
    static let lightMoveAction = "lightMoveAction"
}

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Wizard: UInt32 = 0x1 << 1 // 01
    static let Ground: UInt32 = 0x1 << 2 // 010
    static let Rock:   UInt32 = 0x1 << 3 // 0100
    static let Edge:  UInt32 = 0x1 << 4 // 01000
    static let Arrow: UInt32 = 0x1 << 5
    static let Blood :UInt32 = 0x1 << 6
    static let RadialGravity:  UInt32 = 0x1 << 7
    static let BreakableFormation:  UInt32 = 0x1 << 8
    
    static let vikingBodyPart: UInt32 = 0x1 << 9
    
}

//struct PhysicsCategory {
//    static let None: UInt32              = 0
//    static let Player: UInt32            = 0b1      // 1
//    static let PlatformNormal: UInt32    = 0b10     // 2
//    static let PlatformBreakable: UInt32 = 0b100    // 4
//    static let CoinNormal: UInt32        = 0b1000   // 8
//    static let CoinSpecial: UInt32       = 0b10000  // 16
//    static let Edges: UInt32             = 0b100000 // 32
//}
