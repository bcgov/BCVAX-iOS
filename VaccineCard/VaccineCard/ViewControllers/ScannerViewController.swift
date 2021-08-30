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
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var codeHighlightTags: [Int] = []
    fileprivate var invalidScannedCodes: [String] = []
    
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
        // Remove boxes for previous qr codes
        clearQRCodeLocations()
        // if there are multiple codes in camera view
        if metadataObjects.count > 1 {
            showMultipleQRCodesWarning(metadataObjects: metadataObjects)
            return
        }
        
        // get data from single code in view
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue
              else {
            return
        }
        
        // if code has been invalidated already in this session, avoid blocking the camera
        if !invalidScannedCodes.contains(stringValue) {
            // Pause camera
            captureSession?.stopRunning()
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
            // Feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            // Validate QR code
            validate(code: stringValue)
        } else {
            // Show message
            self.showBanner(message: Constants.Strings.Errors.InvalidCode.message, animatePersentation: true)
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
        }
    }
    
    fileprivate func validate(code: String) {
        hideBanner()
        view.startLoadingIndicator()
        // Validate
        CodeValidationService.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            guard let res = result else {
                // show an error & start camera
                self.showBanner(message: Constants.Strings.Errors.InvalidCode.message, animatePersentation: true)
                self.startCamera()
                self.invalidScannedCodes.append(code)
                return
            }
            self.found(card: res)
        }
        
        // TODO: consider cashing invalid codes for the session to avoid re-validating
    }
    
    public func startCamera() {
        clearQRCodeLocations()
        captureSession?.startRunning()
    }
    
    /// Called when a SMART QR code is found - override this function
    /// - Parameter code: QR code
    func found(card: ScanResultModel) {}
    
    fileprivate func showMultipleQRCodesWarning(metadataObjects: [AVMetadataObject]) {
        for (index, item) in metadataObjects.enumerated() {
            showQRCodeLocation(for: item, isInValid: true, tag: 1000 + index)
        }
        showBanner(message: "There are multiple QR codes in view", animatePersentation: false)
    }
    
    fileprivate func showQRCodeLocation(for object: AVMetadataObject, isInValid: Bool, tag: Int) {
        guard let metadataLocation = previewLayer.transformedMetadataObject(for: object) else {
            return
        }
        if let existing = view.viewWithTag(tag) {
            existing.removeFromSuperview()
        }
        let container = UIView(frame: metadataLocation.bounds)
        container.tag = tag
        container.layer.borderWidth =  Constants.UI.QRCodeHighlighter.borderWidth
        container.layer.borderColor = isInValid ? Constants.UI.QRCodeHighlighter.borderColorInvalid : Constants.UI.QRCodeHighlighter.borderColor
        container.layer.cornerRadius =  Constants.UI.QRCodeHighlighter.cornerRadius
        container.backgroundColor = .clear
        
        codeHighlightTags.append(tag)
        view.addSubview(container)
        
        // If its a known invalid QR code, make show invalid colour
        guard let readableObject = object as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              invalidScannedCodes.contains(stringValue)
              else {
            return
        }
        container.layer.borderColor = Constants.UI.QRCodeHighlighter.borderColorInvalid
    }
    
    fileprivate func clearQRCodeLocations() {
        for tag in codeHighlightTags {
            if let box = view.viewWithTag(tag) {
                box.removeFromSuperview()
            }
        }
    }
    
    
}
