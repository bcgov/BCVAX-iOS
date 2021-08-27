//
//  ScanViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import Foundation
import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: Variables
    public var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Hide Statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Lock in portrait mode
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }
    
    // MARK: Setup
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // Setup Video input
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            alert(title: Constants.Strings.Errors.VideoNotSupported.title,
                  message: Constants.Strings.Errors.VideoNotSupported.message)
            return
        }

        // Setup medatada delegate to capture QR codes
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            alert(title: Constants.Strings.Errors.QRScanningNotSupported.title,
                  message: Constants.Strings.Errors.QRScanningNotSupported.message)
            return
        }

        // Setup Preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Begin Capture Session
        captureSession.startRunning()
    }

    
    /// Medatada Delegate function - called when a QR is found
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        guard let metadataObject = metadataObjects.first else {return}
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        found(code: stringValue)
    }

    /// Called when a QR code is found - override this function & handle string
    /// - Parameter code: QR code
    func found(code: String) {}
}
