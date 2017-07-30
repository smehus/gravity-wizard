//
//  SpriteConfiguration.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/8/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

protocol SpriteConfiguration {
    var name: String { get }
    var categoryBitMask: UInt32 { get }
    var contactTestBitMask: UInt32 { get }
    var collisionBitMask: UInt32  { get }
    var isDynamic: Bool { get }
    var affectedByGravity: Bool { get }
    var allowsRotation: Bool  { get }
}
