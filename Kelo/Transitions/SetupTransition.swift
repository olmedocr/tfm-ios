//
//  CustomTransition.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/4/21.
//

import UIKit

extension SetupTransition {
    enum TransitionType {
        case enter
        case leave
    }
}

public class SetupTransition: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: Properties
    fileprivate let operation: UINavigationController.Operation

    // MARK: Initializers
    init?(withOperation operation: UINavigationController.Operation ) {
        self.operation = operation
    }

    // MARK: Animated transitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.transitionDefaultDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }

        guard let fromAnimatableVC = fromVC as? Animatable,
              let toAnimatableVC = toVC as? Animatable else {
            return
        }

        animate(viewsToAnimate: fromAnimatableVC.getViewsToAnimate(),
                withDuration: Constants.animationDefaultDuration,
                withType: .leave,
                withOperation: operation,
                completion: { _ in
                    containerView.addSubview(toVC.view)
                    self.animate(viewsToAnimate: toAnimatableVC.getViewsToAnimate(),
                                 withDuration: Constants.animationDefaultDuration,
                                 withType: .enter,
                                 withOperation: self.operation,
                                 completion: {_ in
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                                 })

                })

    }

    // MARK: - Internal
    private func animate(viewsToAnimate views: [UIView],
                         withDuration duration: Double,
                         withType type: TransitionType,
                         withOperation operation: UINavigationController.Operation,
                         completion: ((Bool) -> Void)? = nil) {

        let screenWidth = UIScreen.main.bounds.width
        let numberOfViews = views.count
        let delays = Array(stride(from: 0, to: duration, by: duration / Double(numberOfViews)))

        if type == .enter {
            UIView.performWithoutAnimation {
                for view in views {
                    if operation == .push {
                        view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
                    } else if operation == .pop {
                        view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
                    } else {
                        log.warning("Unsupported operation")
                    }
                }
            }
        }

        let group = DispatchGroup()

        for (index, view) in views.enumerated() {
            group.enter()

            UIView.animate(
                withDuration: duration,
                delay: delays[index],
                animations: { [weak view] in
                    switch type {
                    case .enter:
                        view?.transform = CGAffineTransform(translationX: 0, y: 0)

                    case .leave:
                        if operation == .push {
                            view?.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
                        } else if operation == .pop {
                            view?.transform = CGAffineTransform(translationX: screenWidth, y: 0)
                        } else {
                            log.warning("Unsupported operation")
                        }
                    }
                },
                completion: { _ in
                    group.leave()
                }
            )
        }

        group.notify(queue: .main) {
            if let completion = completion {
                completion(true)
            }
        }
    }
}
