//
//  HalfPresentationController.swift
//  QR Scanner (Vezdekod)
//
//  Created by Alex Yatsenko on 25.04.2021.
//

import UIKit

class HalfPresentationController: UIPresentationController {

  private let blurEffectView: UIVisualEffectView?
  private var tapGestureRecognizer: UITapGestureRecognizer?

  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    let blurEffect = UIBlurEffect(style: .dark)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
    blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurEffectView?.isUserInteractionEnabled = true
    if let tapGestureRecognizer = tapGestureRecognizer {
      blurEffectView?.addGestureRecognizer(tapGestureRecognizer)
    }
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    return CGRect(origin: CGPoint(x: 0, y: (containerView?.frame.height ?? 0) / 2), size: CGSize(width: (containerView?.frame.width ?? 0), height: (containerView?.frame.height ?? 0) / 2))
  }

  override func dismissalTransitionWillBegin() {
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
      self.blurEffectView?.alpha = 0
    }) { _ in
      self.blurEffectView?.removeFromSuperview()
    }
  }
  override func presentationTransitionWillBegin() {
    blurEffectView?.alpha = 0
    if let blurEffectView = blurEffectView{
      containerView?.addSubview(blurEffectView)
    }
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.blurEffectView?.alpha = 1
    })
  }
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    presentedView?.layer.masksToBounds = true
    presentedView?.layer.cornerRadius = 10
  }
  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
    blurEffectView?.frame = containerView!.bounds
  }

  @objc private func dismiss() {
    presentedViewController.dismiss(animated: true)
  }
}
