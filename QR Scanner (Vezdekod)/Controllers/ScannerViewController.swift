//
//  ScannerViewController.swift
//  QR Scanner (Vezdekod)
//
//  Created by Alex Yatsenko on 25.04.2021.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIViewControllerTransitioningDelegate {
    
  private let session = AVCaptureSession()
  private var video: AVCaptureVideoPreviewLayer?
  private var scannedText: String?
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
  override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupVideo()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startRunning()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let resultVC = segue.destination as? ResultViewController {
      resultVC.modalPresentationStyle = .custom
      resultVC.transitioningDelegate = self
      resultVC.scannedText = scannedText
    }
  }
  
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return HalfPresentationController(presentedViewController: presented, presenting: presenting)
  }
  
  private func setupVideo() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      if session.canAddInput(input) {
        session.addInput(input)
      }
    } catch let error {
      print(error.localizedDescription)
    }
    let output = AVCaptureMetadataOutput()
    if session.canAddOutput(output) {
      session.addOutput(output)
    }
    
    output.setMetadataObjectsDelegate(self, queue: .main)
    output.metadataObjectTypes = [.qr]
    
    video = AVCaptureVideoPreviewLayer(session: session)
    video?.videoGravity = .resizeAspectFill
    video?.frame = view.layer.bounds
  }
  
  private func startRunning() {
    if let video = video {
      view.layer.addSublayer(video)
      session.startRunning()
    }
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {
    guard !metadataObjects.isEmpty else { return }
    if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
      scannedText = object.stringValue
      if object.type == .qr, presentedViewController == nil {
        performSegue(withIdentifier: "showDetail", sender: nil)
      }
    }
  }
}
