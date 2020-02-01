//
//  NotOptimizedCounterViewController.swift
//  LazyInitializedViewModelInjectionSample
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine
import NotOptimized
import UIKit

final class NotOptimizedCounterViewController: UIViewController {

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

    typealias InitViewModel = (Int, AnyPublisher<Void, Never>, AnyPublisher<Void, Never>) -> CounterViewModelType

    private var count: Int!
    private var initViewModel: InitViewModel!
    private lazy var viewModel = initViewModel(
        count,
        incrementButton.extension.tap(),
        decrementButton.extension.tap()
    )
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

    static func makeFromStoryboard(count: Int, initViewModel: @escaping InitViewModel) -> NotOptimizedCounterViewController {
        let storyboard = UIStoryboard(name: "NotOptimizedCounterViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! NotOptimizedCounterViewController
        viewController.count = count
        viewController.initViewModel = initViewModel
        return viewController
    }
}
