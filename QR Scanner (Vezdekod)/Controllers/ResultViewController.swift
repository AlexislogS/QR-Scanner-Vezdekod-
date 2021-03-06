//
//  ResultViewController.swift
//  QR Scanner (Vezdekod)
//
//  Created by Alex Yatsenko on 25.04.2021.
//

import UIKit

extension String {

    // MARK: Get remove all characters exept numbers

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }

}

class ResultViewController: UIViewController {
  
  @IBOutlet private weak var actionButton: UIButton!
  @IBOutlet private weak var textLabel: UILabel! { didSet { textLabel.text = scannedText } }
  
  enum ResultType {
    case phone, web, text
  }
  
  var scannedText: String?
  private var hasSetPointOrigin = false
  private var pointOrigin: CGPoint?
  private var pulse: Pulsing?
  private var resultType: ResultType = .text
  
  override func viewDidLoad() {
    super.viewDidLoad()
    actionButton.layer.cornerRadius = actionButton.bounds.width / 2
    view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dismissVC(sender:))))
    if scannedText?.hasPrefix("TEL") == true {
      textLabel.text?.append("\n\n(phone number)")
      resultType = .phone
    } else if scannedText?.hasPrefix("http") == true {
      resultType = .web
      textLabel.text?.append("\n\n(website)")
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    addPulseAnimation()
  }
  
  override func viewDidLayoutSubviews() {
    if !hasSetPointOrigin {
      hasSetPointOrigin = true
      pointOrigin = view.frame.origin
    }
  }
  
  @IBAction func actionButtonPressed() {
    guard let scannedText = scannedText else { return }
    if resultType != .text, let url = URL(string: scannedText) {
      UIApplication.shared.open(url)
    } else {
      let activityVC = UIActivityViewController(activityItems: [scannedText], applicationActivities: nil)
      present(activityVC, animated: true)
    }
  }
  
  private func addPulseAnimation() {
    pulse = Pulsing(radius: actionButton.bounds.width * 1.15, position: actionButton.center)
    if let pulse = pulse {
      pulse.backgroundColor = UIColor.systemTeal.cgColor
      view.layer.insertSublayer(pulse, below: actionButton.layer)
    }
  }
  
  @objc private func dismissVC(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    guard translation.y >= 0 else { return }
    view.frame.origin = CGPoint(x: 0, y: pointOrigin?.y ?? 0 + translation.y)
    
    if sender.state == .ended {
      let dragVelocity = sender.velocity(in: view)
      if dragVelocity.y >= 1300 {
        dismiss(animated: true, completion: nil)
      } else {
        UIView.animate(withDuration: 0.3) {
          self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
        }
      }
    }
  }
}
