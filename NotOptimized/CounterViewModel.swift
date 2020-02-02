//
//  CounterViewModel.swift
//  NotOptimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine

public protocol CounterViewModelType {
    var countText: AnyPublisher<String?, Never> { get }
    var isDecrementEnabled: AnyPublisher<Bool, Never> { get }
}

public final class CounterViewModel: CounterViewModelType {

    public let countText: AnyPublisher<String?, Never>
    public let isDecrementEnabled: AnyPublisher<Bool, Never>

    private var cancellables = [AnyCancellable]()

    public init(count: Int,
                increment: AnyPublisher<Void, Never>,
                decrement: AnyPublisher<Void, Never>) {
        let store = Store()
        store.count = count

        self.countText = store.$count.map(String.init)
            .eraseToAnyPublisher()

        self.isDecrementEnabled = store.$count.map { $0 > 0 }
            .eraseToAnyPublisher()

        increment.map { _ in 1 }
            .merge(with: decrement.map { _ in -1 })
            .flatMap { Just(store.count + $0) }
            .assign(to: \.count, on: store)
            .store(in: &cancellables)
    }

    private final class Store {
        @Published var count = 0
    }
}
