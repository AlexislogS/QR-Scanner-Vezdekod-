//
//  Pulsing.swift
//  QR Scanner (Vezdekod)
//
//  Created by Alex Yatsenko on 25.04.2021.
//

import UIKit

class Pulsing: CALayer {

  var initialPulseScale: Float = 0
  var nextPulseAfter: TimeInterval = 0
  var animationDuration: TimeInterval = 1
  var radius: CGFloat = 200
  var numberOfPulses: Float = .infinity

  private var animationGroup = CAAnimationGroup()

  override init(layer: Any) {
    super.init(layer: layer)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  init(numberOfPulses: Float = .infinity, radius: CGFloat, position: CGPoint) {
    super.init()

    self.backgroundColor = UIColor.black.cgColor
    self.contentsScale = UIScreen.main.scale
    self.opacity = 0
    self.radius = radius
    self.numberOfPulses = numberOfPulses
    self.position = position

    self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
    self.cornerRadius = radius

    DispatchQueue.global(qos: .default).async {
      self.setupAnimationGroup()
      DispatchQueue.main.async {
        self.add(self.animationGroup, forKey: "pulse")
      }
    }
  }

  private func createScaleAnimation () -> CABasicAnimation {
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
    scaleAnimation.fromValue = NSNumber(value: initialPulseScale)
    scaleAnimation.toValue = NSNumber(value: 1)
    scaleAnimation.duration = animationDuration
    return scaleAnimation
  }

  private func createOpacityAnimation() -> CAKeyframeAnimation {
    let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
    opacityAnimation.duration = animationDuration
    opacityAnimation.values = [0.4, 0.8, 0]
    opacityAnimation.keyTimes = [0, 0.2, 1]
    return opacityAnimation
  }

  private func setupAnimationGroup() {
    self.animationGroup = CAAnimationGroup()
    self.animationGroup.duration = animationDuration + nextPulseAfter
    self.animationGroup.repeatCount = numberOfPulses

    let defaultCurve = CAMediaTimingFunction(name: .default)
    self.animationGroup.timingFunction = defaultCurve
    self.animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
  }
}

