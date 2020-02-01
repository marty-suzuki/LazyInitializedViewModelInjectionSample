//
//  OptimizedCounterViewControllerTests.swift
//  LazyInitializedViewModelInjectionSampleTests
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine
import Optimized
import UIKit
import XCTest
@testable import LazyInitializedViewModelInjectionSample

class OptimizedCounterViewControllerTests: XCTestCase {

    private var viewController: OptimizedCounterViewController!
    private var viewModel: MockCounterViewModel!
    private var factory: MockFactory!

    override func setUp() {
        viewModel = MockCounterViewModel()
        factory = MockFactory(viewModel)
        viewController = OptimizedCounterViewController.makeFromStoryboard(factory: factory)
        viewController.loadViewIfNeeded()
    }

    func test_incrementButton_event() {
        let response = CurrentValueSubject<Void?, Never>(nil)

        let cancellable = factory.increment
            .map(Optional.some)
            .subscribe(response)

        viewController.incrementButton.sendActions(for: .touchUpInside)

        XCTAssertNotNil(response.value)
        cancellable.cancel()
    }

    func test_decrementButton_event() {
        let response = CurrentValueSubject<Void?, Never>(nil)

        let cancellable = factory.decrement
            .map(Optional.some)
            .subscribe(response)

        viewController.decrementButton.sendActions(for: .touchUpInside)

        XCTAssertNotNil(response.value)
        cancellable.cancel()
    }

    func test_countLabel_text() {
        let expected = UUID().uuidString
        viewModel._countText.send(expected)
        XCTAssertEqual(viewController.countLabel.text, expected)
    }

    func test_decrementButton_isEnabled() {
        let expected = false
        viewModel._isDecrementEnabled.send(expected)
        XCTAssertEqual(viewController.decrementButton.isEnabled, expected)
    }
}

extension OptimizedCounterViewControllerTests {

    private final class MockCounterViewModel: CounterViewModelType {

        let countText: AnyPublisher<String?, Never>
        let _countText = PassthroughSubject<String?, Never>()

        let isDecrementEnabled: AnyPublisher<Bool, Never>
        let _isDecrementEnabled = PassthroughSubject<Bool, Never>()

        init() {
            self.countText = _countText.eraseToAnyPublisher()
            self.isDecrementEnabled = _isDecrementEnabled.eraseToAnyPublisher()
        }
    }

    private final class MockFactory: ViewModelFactoryType {

        let increment = PassthroughSubject<Void, Never>()
        let decrement = PassthroughSubject<Void, Never>()

        private let viewModel: MockCounterViewModel
        private var cancellables: [AnyCancellable] = []

        init(_ viewModel: MockCounterViewModel) {
            self.viewModel = viewModel
        }

        func initialize(_ dependency: CounterViewModelFactory.Dependency) -> CounterViewModelType {
            dependency.increment
                .subscribe(increment)
                .store(in: &cancellables)

            dependency.decrement
                .subscribe(decrement)
                .store(in: &cancellables)

            return viewModel
        }
    }
}
