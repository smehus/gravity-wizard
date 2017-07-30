//
//  GameLevel.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

protocol GameLevel {
    var currentLevel: Level { get }
}

extension GameLevel {
    var currentLevel: Level {
        fatalError("Subclasses should override this stored property")
    }
}
