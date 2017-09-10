//
//  StateMachine.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

protocol StateProtocol: Hashable { }

protocol StateMachineDelegate {
    associatedtype State
    
    func getNextState(state: State) -> State
    func switchState(state: State, toState: State) -> State
}

class StateMachine<DefinedState: StateProtocol, Delegate: StateMachineDelegate> where Delegate.State == DefinedState {
    
    var state: DefinedState
    var delegate: Delegate
    
    init(delegate: Delegate, initialState: DefinedState) {
        self.state = initialState
        self.delegate = delegate
    }
    
    func update() {
        let nextState = delegate.getNextState(state: state)
        guard nextState != state else { return }
        state = delegate.switchState(state: state, toState: nextState)
    }
}
