//
//  PushTransition.swift
//  ownCloud
//
//  Created by Felix Schwarz on 22.04.19.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2019, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

import UIKit

class PushTransition: NSObject, UIViewControllerAnimatedTransitioning {
	var dismissTransition : Bool = false

	init(dismiss: Bool) {
		dismissTransition = dismiss
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let fromViewController = transitionContext.viewController(forKey: .from),
		   let toViewController = transitionContext.viewController(forKey: .to) {

			if dismissTransition {
				fromViewController.view.frame = transitionContext.initialFrame(for: fromViewController)
				toViewController.view.frame = transitionContext.finalFrame(for: toViewController)

				transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

				fromViewController.view.transform = .identity
				toViewController.view.transform = CGAffineTransform(translationX: -0.5 * toViewController.view.frame.size.width, y: 0)

				UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: [ .curveEaseInOut ], animations: {
					fromViewController.view.transform = CGAffineTransform(translationX: fromViewController.view.frame.size.width, y: 0)
					toViewController.view.transform = .identity
				}, completion: { _ in
					let window = fromViewController.view.window

					fromViewController.view.transform = .identity
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

					// Work around an iOS bug where usting a custom dismissal animation removes both from and to view controllers
					if !transitionContext.transitionWasCancelled, let window = window {
						if toViewController.view.window == nil {
							window.addSubview(toViewController.view)
						}
					}
				})
			} else {
				fromViewController.view.frame = transitionContext.finalFrame(for: fromViewController)
				toViewController.view.frame = transitionContext.finalFrame(for: toViewController)

				transitionContext.containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)

				toViewController.view.transform = CGAffineTransform(translationX: toViewController.view.frame.size.width, y: 0)

				UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: [ .curveEaseInOut ], animations: {
					fromViewController.view.transform = CGAffineTransform(translationX: -0.5 * fromViewController.view.frame.size.width, y: 0)
					toViewController.view.transform = .identity
				}, completion: { _ in
					fromViewController.view.transform = .identity
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				})
			}
		}
	}
}
