//
//  CounterViewModelFactory.swift
//  Optimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine

public protocol ViewModelFactoryType {
    associatedtype Dependency
    associatedtype ViewModel
    func initialize(_ dependency: Dependency) -> ViewModel
}

public struct AnyViewModelFactory<Dependency, ViewModel>: ViewModelFactoryType {

    private let _initialize: (Dependency) -> ViewModel

    public init<Factory: ViewModelFactoryType>(_ factory: Factory) where Factory.Dependency == Dependency, Factory.ViewModel == ViewModel {
        self._initialize = { factory.initialize($0) }
    }

    public func initialize(_ dependency: Dependency) -> ViewModel {
        _initialize(dependency)
    }
}

public struct CounterViewModelFactory: ViewModelFactoryType {

    private let count: Int

    public init(count: Int) {
        self.count = count
    }

    public func initialize(_ dependency: (
        increment: AnyPublisher<Void, Never>,
        decrement: AnyPublisher<Void, Never>
    )) -> CounterViewModelType {
        CounterViewModel(count: count,
                         increment: dependency.increment,
                         decrement: dependency.decrement)
    }
}
