//
//  UIControl.extension.swift
//  LazyInitializedViewModelInjectionSample
//
//  Created by marty-suzuki on 2020/02/01.
//  Copyright © 2020 marty-suzuki. All rights reserved.
//

import Combine
import UIKit

protocol ExtensionCompatible {
    associatedtype ExtensionBase
    var `extension`: Extension<ExtensionBase> { get }
}

extension ExtensionCompatible {
    var `extension`: Extension<Self> { Extension<Self>(base: self) }
}

struct Extension<Base> {
    let base: Base
}

extension NSObject: ExtensionCompatible {}

extension Extension where Base: UIControl {

    final class Subscription<Subscriber: Combine.Subscriber>: Combine.Subscription where Subscriber.Input == UIControl {
        private var subscriber: Subscriber?

        init(subscriber: Subscriber, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            control.addTarget(self, action: #selector(action(_:)), for: event)
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
        }

        @objc private func action(_ control: UIControl) {
            _ = subscriber?.receive(control)
        }
    }

    struct Publisher: Combine.Publisher {

        typealias Output = UIControl
        typealias Failure = Never

        let control: UIControl
        let controlEvents: UIControl.Event

        init(control: UIControl, events: UIControl.Event) {
            self.control = control
            self.controlEvents = events
        }

        func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Extension<UIControl>.Subscription(subscriber: subscriber, control: control, event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }

    func publisher(for events: UIControl.Event) -> Extension<UIControl>.Publisher {
        return Extension<UIControl>.Publisher(control: base, events: events)
    }

    func tap() -> AnyPublisher<Void, Never> {
        publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    }
}
