//
//  CounterViewModelFactory.swift
//  LittleOptimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine

public protocol ViewModelFactoryType {
    associatedtype Dependency
    associatedtype ViewModel
    typealias Initializer = (Dependency) -> ViewModel
    static func initialize(_ dependency: Dependency) -> ViewModel
}

public enum CounterViewModelFactory: ViewModelFactoryType {

    public static func initialize(_ dependency: (
        count: Int,
        increment: AnyPublisher<Void, Never>,
        decrement: AnyPublisher<Void, Never>
    )) -> CounterViewModelType {
        CounterViewModel(dependency)
    }
}
