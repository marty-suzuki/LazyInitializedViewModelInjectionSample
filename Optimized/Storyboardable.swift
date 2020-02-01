//
//  Storyboardable.swift
//  Optimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import UIKit

public protocol Storyboardable: AnyObject {
    associatedtype Dependency
    associatedtype ViewModel
    associatedtype Instance

    static var storyboard: UIStoryboard { get }
    static var storyboardName: String { get }
    static var identifier: String { get }

    var factory: AnyViewModelFactory<Dependency, ViewModel>! { get set }

    static func makeFromStoryboard<Factory: ViewModelFactoryType>(factory: Factory) -> Instance where Factory.Dependency == Dependency, Factory.ViewModel == ViewModel
}

extension Storyboardable {

    public static var storyboardName: String {
        String(describing: self)
    }

    public static var identifier: String {
        String(describing: self)
    }

    public static var storyboard: UIStoryboard {
        UIStoryboard(name: storyboardName, bundle: nil)
    }

    public static func unsafeMakeFromStoryboard() -> Self {
        storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }

    public static func makeFromStoryboard<Factory: ViewModelFactoryType>(factory: Factory) -> Self where Factory.Dependency == Dependency, Factory.ViewModel == ViewModel {
        let instance = unsafeMakeFromStoryboard()
        instance.factory = AnyViewModelFactory(factory)
        return instance
    }
}
