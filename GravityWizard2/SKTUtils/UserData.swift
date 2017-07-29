//
//  UserData.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/28/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

enum UserDataError: Error {
    case initFailed
}

protocol StringInitable {
    init?(string: String)
}
