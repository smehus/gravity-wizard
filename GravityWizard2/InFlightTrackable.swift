//
//  InFlightTrackable.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol InFlightTrackable: class {
    var isInFlight: Bool { get set }
    func launch(at vector: CGVector)
    func collide()
}

extension InFlightTrackable where Self: SKNode {
    func launch(at vector: CGVector) {
        isInFlight = true
        guard let body = physicsBody else { return }
        body.velocity = vector
    }
}

extension InFlightTrackable where Self: SKSpriteNode {
    func launch(at vector: CGVector) {
        isInFlight = true
        guard let body = physicsBody else { return }
        body.velocity = vector
        
    }
}
