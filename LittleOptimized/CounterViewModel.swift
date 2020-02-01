//
//  CounterViewModel.swift
//  LittleOptimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine

public protocol CounterViewModelType {
    var countText: AnyPublisher<String?, Never> { get }
    var isDecrementEnabled: AnyPublisher<Bool, Never> { get }
}

internal final class CounterViewModel: CounterViewModelType {

    internal let countText: AnyPublisher<String?, Never>
    internal let isDecrementEnabled: AnyPublisher<Bool, Never>

    private var cancellables = [AnyCancellable]()

    internal init(_ dependency: CounterViewModelFactory.Dependency) {
        let store = Store()
        store.count = dependency.count

        self.countText = store.$count.map(String.init)
            .eraseToAnyPublisher()

        self.isDecrementEnabled = store.$count.map { $0 > 0 }
            .eraseToAnyPublisher()

        dependency.increment.map { _ in 1 }
            .merge(with: dependency.decrement.map { _ in -1 })
            .flatMap { Just(store.count + $0) }
            .assign(to: \.count, on: store)
            .store(in: &cancellables)
    }

    private final class Store {
        @Published var count = 0
    }
}
