//
//  Storyboardable.swift
//  LittleOptimized
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import UIKit

public protocol Storyboardable: AnyObject {
    associatedtype Dependency
    associatedtype ViewModelDependency
    associatedtype ViewModel
    associatedtype Instance

    static var storyboard: UIStoryboard { get }
    static var storyboardName: String { get }
    static var identifier: String { get }

    var initViewModel: ((ViewModelDependency) -> ViewModel)! { get set }
    var dependency: Dependency! { get set }

    static func makeFromStoryboard(dependency: Dependency, initViewModel: @escaping (ViewModelDependency) -> ViewModel) -> Instance
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

    public static func makeFromStoryboard(dependency: Dependency, initViewModel: @escaping (ViewModelDependency) -> ViewModel) -> Self {
        let instance = unsafeMakeFromStoryboard()
        instance.dependency = dependency
        instance.initViewModel = initViewModel
        return instance
    }
}

