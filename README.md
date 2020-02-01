# How to inject lazy initialized ViewModel with Storyboard

It is hard to inject an instance of ViewModel that is initialized lazily.

```swift
final class CounterViewController: UIViewController {

    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    private lazy var viewModel = CounterViewModel( // 👈 How to inject this
        count: dependency,
        increment: incrementButton.extension.tap(),
        decrement: decrementButton.extension.tap()
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
}
```

## 1.  Inject an initializer as a closure

[NotOptimizedCounterViewController.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSample/NotOptimized/NotOptimizedCounterViewController.swift)

```swift
final class NotOptimizedCounterViewController: UIViewController {
    ...

    typealias InitViewModel = (Int, AnyPublisher<Void, Never>, AnyPublisher<Void, Never>) -> CounterViewModelType

    private var count: Int!
    private var initViewModel: InitViewModel!
    private lazy var viewModel = initViewModel(
        count,
        incrementButton.extension.tap(),
        decrementButton.extension.tap()
    )

    ...

    static func makeFromStoryboard(count: Int, initViewModel: @escaping InitViewModel) -> NotOptimizedCounterViewController {
        let storyboard = UIStoryboard(name: "NotOptimizedCounterViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! NotOptimizedCounterViewController
        viewController.count = count
        viewController.initViewModel = initViewModel
        return viewController
    }
}
```

### ViewModel Protocol

[CounterViewModel](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/NotOptimized/CounterViewModel.swift)

```swift
public protocol CounterViewModelType {
    var countText: AnyPublisher<String?, Never> { get }
    var isDecrementEnabled: AnyPublisher<Bool, Never> { get }
    init(count: Int,
         increment: AnyPublisher<Void, Never>,
         decrement: AnyPublisher<Void, Never>)
}
```

### How to initialize ViewController

- Development Code

```swift
NotOptimizedCounterViewController.makeFromStoryboard(count: 0, initViewModel: CounterViewModel.init)
```

- Test Code

[NotOptimizedCounterViewControllerTests.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSampleTests/NotOptimizedCounterViewControllerTests.swift)

```swift
NotOptimizedCounterViewController.makeFromStoryboard(count: 0, initViewModel: MockCounterViewModel.init)
```

## 2. Inject a mockable staic method as a closure

[LittleOptimizedCounterViewController.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSample/LittleOptimized/LittleOptimizedCounterViewController.swift)

```swift
final class LittleOptimizedCounterViewController: UIViewController, Storyboardable {

    ...

    var dependency: Int!
    var initViewModel: CounterViewModelFactory.Initializer!
    private lazy var viewModel = initViewModel((
        count: dependency,
        increment: incrementButton.extension.tap(),
        decrement: decrementButton.extension.tap()
    ))
    
    ...
}
```

### ViewModel Protocol

[CounterViewModel.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LittleOptimized/CounterViewModel.swift)

```swift
public protocol CounterViewModelType {
    var countText: AnyPublisher<String?, Never> { get }
    var isDecrementEnabled: AnyPublisher<Bool, Never> { get }
}
```

### ViewModelFactory

[CounterViewModelFactory.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LittleOptimized/CounterViewModelFactory.swift)

```swift
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
```

### Storyboard Protocol

[Storyboardable.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LittleOptimized/Storyboardable.swift)

```swift
public protocol Storyboardable: AnyObject {
    associatedtype Dependency
    associatedtype ViewModelDependency
    associatedtype ViewModel
    associatedtype Instance

    ...

    var initViewModel: ((ViewModelDependency) -> ViewModel)! { get set }
    var dependency: Dependency! { get set }

    static func makeFromStoryboard(dependency: Dependency, initViewModel: @escaping (ViewModelDependency) -> ViewModel) -> Instance
}

extension Storyboardable {

    ...

    public static func makeFromStoryboard(dependency: Dependency, initViewModel: @escaping (ViewModelDependency) -> ViewModel) -> Self {
        let instance = unsafeMakeFromStoryboard()
        instance.dependency = dependency
        instance.initViewModel = initViewModel
        return instance
    }
}
```

### How to initialize ViewController

- Development Code

```swift
LittleOptimizedCounterViewController.makeFromStoryboard(dependency: 0, initViewModel: CounterViewModelFactory.initialize)
```

- Test Code

[LittleOptimizedCounterViewControllerTests.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSampleTests/LittleOptimizedCounterViewControllerTests.swift)

```swift
LittleOptimizedCounterViewController.makeFromStoryboard(dependency: 0, initViewModel: MockCounterViewModelFactory.initialize)
```

## 3. Inject a mockable factor

[OptimizedCounterViewController.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSample/Optimized/OptimizedCounterViewController.swift)

```swift
final class OptimizedCounterViewController: UIViewController, Storyboardable {

    ...

    var factory: AnyViewModelFactory<CounterViewModelFactory.Dependency, CounterViewModelType>!
    private lazy var viewModel = factory.initialize((
        increment: incrementButton.extension.tap(),
        decrement: decrementButton.extension.tap()
    ))

    ...
}
```

### ViewModel Protocol

[CounterViewModel.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/Optimized/CounterViewModel.swift)

```swift
public protocol CounterViewModelType {
    var countText: AnyPublisher<String?, Never> { get }
    var isDecrementEnabled: AnyPublisher<Bool, Never> { get }
}
```

### ViewModelFactory

[CounterViewModelFactory.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/Optimized/CounterViewModelFactory.swift)

```swift
public protocol ViewModelFactoryType {
    associatedtype Dependency
    associatedtype ViewModel
    func initialize(_ dependency: Dependency) -> ViewModel
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
```

### Storyboard Protocol

[Storyboardable.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/Optimized/Storyboardable.swift)

```swift
public protocol Storyboardable: AnyObject {
    associatedtype Dependency
    associatedtype ViewModel
    associatedtype Instance

    ...

    var factory: AnyViewModelFactory<Dependency, ViewModel>! { get set }

    static func makeFromStoryboard<Factory: ViewModelFactoryType>(factory: Factory) -> Instance where Factory.Dependency == Dependency, Factory.ViewModel == ViewModel
}

extension Storyboardable {

    ...

    public static func makeFromStoryboard<Factory: ViewModelFactoryType>(factory: Factory) -> Self where Factory.Dependency == Dependency, Factory.ViewModel == ViewModel {
        let instance = unsafeMakeFromStoryboard()
        instance.factory = AnyViewModelFactory(factory)
        return instance
    }
}
```

### How to initialize ViewController

- Development Code

```swift
OptimizedCounterViewController.makeFromStoryboard(factory: CounterViewModelFactory(count: 0))
```

- Test Code

[OptimizedCounterViewControllerTests.swift](https://github.com/marty-suzuki/LazyInitializedViewModelInjectionSample/blob/master/LazyInitializedViewModelInjectionSampleTests/OptimizedCounterViewControllerTests.swift)

```swift
OptimizedCounterViewController.makeFromStoryboard(factory: MockCounterViewModelFactory())
```

## Requirements

- Xcode 11.3.1
- iOS13
    - To use Combine.framework
    - Not to use [static func instantiateInitialViewController(creator:)](https://developer.apple.com/documentation/uikit/uistoryboard/3213988-instantiateinitialviewcontroller) on purpose