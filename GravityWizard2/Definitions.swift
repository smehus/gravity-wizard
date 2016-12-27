//
//  Definitions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import Foundation

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
    static let Wizard: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Rock:   UInt32 = 0x1 << 3
    static let Edge:  UInt32 = 0x1 << 4
    static let Arrow: UInt32 = 0x1 << 5
    static let Blood :UInt32 = 0x1 << 6
    static let RadialGravity:  UInt32 = 0x1 << 7
    static let BreakableFormation:  UInt32 = 0x1 << 8
}
