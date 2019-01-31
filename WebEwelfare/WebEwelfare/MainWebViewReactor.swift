//
//  MainWebViewReactor.swift
//  WebEwelfare
//
//  Created by nam yeon hun on 03/01/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

class MainWebViewReactor : Reactor {
    
    enum Action {
        case setToken
    }
    
    enum Mutation {
        case SetToken
    }
    
    struct State { }
    
    let initialState : State = State()
    
    let network = NetworkingService()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setToken:
            return network.request(.fcm).asObservable()
                .map { _ in Mutation.SetToken }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
