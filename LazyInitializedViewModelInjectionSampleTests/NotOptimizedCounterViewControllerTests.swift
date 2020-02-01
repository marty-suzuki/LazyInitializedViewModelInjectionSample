//
//  NotOptimizedCounterViewControllerTests.swift
//  LazyInitializedViewModelInjectionSampleTests
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine
import NotOptimized
import UIKit
import XCTest
@testable import LazyInitializedViewModelInjectionSample

class NotOptimizedCounterViewControllerTests: XCTestCase {

    private var viewController: NotOptimizedCounterViewController!
    private var viewModel: MockCounterViewModel!

    override func setUp() {
        let viewModel = MockCounterViewModel()
        self.viewModel = viewModel
        viewController = NotOptimizedCounterViewController.makeFromStoryboard(count: 0) { count, increment, decrement in
            viewModel._count.send(count)
            increment.subscribe(viewModel._increment).store(in: &viewModel.cancellables)
            decrement.subscribe(viewModel._decrement).store(in: &viewModel.cancellables)
            return viewModel
        }
        viewController.loadViewIfNeeded()
    }

    func test_incrementButton_event() {
        let response = CurrentValueSubject<Void?, Never>(nil)

        let cancellable = viewModel._increment
            .map(Optional.some)
            .subscribe(response)

        viewController.incrementButton.sendActions(for: .touchUpInside)

        XCTAssertNotNil(response.value)
        cancellable.cancel()
    }

    func test_decrementButton_event() {
        let response = CurrentValueSubject<Void?, Never>(nil)

        let cancellable = viewModel._decrement
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

extension NotOptimizedCounterViewControllerTests {

    private final class MockCounterViewModel: CounterViewModelType {

        let countText: AnyPublisher<String?, Never>
        let _countText = PassthroughSubject<String?, Never>()

        let isDecrementEnabled: AnyPublisher<Bool, Never>
        let _isDecrementEnabled = PassthroughSubject<Bool, Never>()

        let _increment = PassthroughSubject<Void, Never>()
        let _decrement = PassthroughSubject<Void, Never>()
        let _count = CurrentValueSubject<Int?, Never>(nil)

        var cancellables: [AnyCancellable] = []

        init(count: Int, increment: AnyPublisher<Void, Never>, decrement: AnyPublisher<Void, Never>) {
            self.countText = _countText.eraseToAnyPublisher()
            self.isDecrementEnabled = _isDecrementEnabled.eraseToAnyPublisher()
        }

        convenience init() {
            self.init(count: 0,
                      increment: Empty().eraseToAnyPublisher(),
                      decrement: Empty().eraseToAnyPublisher())
        }
    }
}

