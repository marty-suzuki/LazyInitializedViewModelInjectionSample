//
//  LittleOptimizedCounterViewController.swift
//  LazyInitializedViewModelInjectionSample
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine
import LittleOptimized
import UIKit

final class LittleOptimizedCounterViewController: UIViewController, Storyboardable {

    @IBOutlet private(set) weak var incrementButton: UIButton! {
        didSet {
            incrementButton.setTitle("🔼", for: [])
            incrementButton.titleLabel?.font = .systemFont(ofSize: 44)
        }
    }

    @IBOutlet private(set) weak var decrementButton: UIButton! {
        didSet {
            decrementButton.setTitle("🔽", for: [])
            decrementButton.titleLabel?.font = .systemFont(ofSize: 44)
        }
    }

    @IBOutlet private(set) weak var countLabel: UILabel! {
        didSet {
            countLabel.textAlignment = .center
            countLabel.font = .systemFont(ofSize: 44)
        }
    }

    @IBOutlet private weak var containerStackView: UIStackView! {
        didSet {
            containerStackView.spacing = 8
        }
    }

    var dependency: Int!
    var initViewModel: CounterViewModelFactory.Initializer!
    private lazy var viewModel = initViewModel((
        count: dependency,
        increment: incrementButton.extension.tap(),
        decrement: decrementButton.extension.tap()
    ))
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.countText
            .assign(to: \.text, on: countLabel)
            .store(in: &cancellables)

        viewModel.isDecrementEnabled
            .assign(to: \.isEnabled, on: decrementButton)
            .store(in: &cancellables)
    }
}
