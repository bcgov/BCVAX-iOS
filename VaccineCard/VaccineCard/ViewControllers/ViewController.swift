//
//  ViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit
import AVFoundation
import BCVaccineValidator

class ViewController: UIViewController {
    
    // MARK: Constants
    private let flashOnIcon = UIImage(named: "flashOn")
    private let flashOffIcon = UIImage(named: "flashOff")
    
    // MARK: Variables
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var codeHighlightTags: [Int] = []
    fileprivate var invalidScannedCodes: [String] = []
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    // Hide Statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Lock in portrait mode
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
        case .pad:
            return [.portrait, .portraitUpsideDown, .landscape]
        case .phone:
            return .portrait
        case .tv:
            return .portrait
        default:
            return .portrait
        }
    }
    
    enum Segues: String {
        case showScanResult = "showScanResult"
    }
    
    private var result: ScanResultModel? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.UI.Theme.primaryColor
        showCameraOrOnboarding()
        Notification.Name.keysUpdated.onPost(object: nil, queue: .main) { [weak self] _ in
            guard let `self` = self else {return}
            self.invalidScannedCodes.removeAll()
        }
        Notification.Name.issuersUpdated.onPost(object: nil, queue: .main) { [weak self] _ in
            guard let `self` = self else {return}
            self.invalidScannedCodes.removeAll()
        }
        Notification.Name.vaccinationRulesUpdated.onPost(object: nil, queue: .main) { [weak self] _ in
            guard let `self` = self else {return}
            self.invalidScannedCodes.removeAll()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
            setFlash(on: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            pauseCamera()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self](context) in
            guard let `self` = self, self.isCameraUsageAuthorized() else { return }
            self.reStartCamera()
        })
    }
    
    private func reStartCamera() {
        DispatchQueue.main.async {
            self.setupCaptureSession()
            self.addFlashlightButton()
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak self] in
                guard let `self` = self else {return}
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
           id == Segues.showScanResult.rawValue,
           let destination = segue.destination as? ScanResultViewController,
           let result = result
        {
            // Disable swipe to dismiss
            if #available(iOS 13.0, *) {
                destination.isModalInPresentation = true
            } else {
                destination.modalPresentationStyle = .fullScreen
            }
            
            if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
                DispatchQueue.main.async {
                    self.removeCameraCutout()
                    self.clearQRCodeLocations()
                    self.removeCameraPreview()
                }
            }
            
            // Set values on result controller
            destination.setup(model: result) { [weak self] in
                guard let `self` = self else {return}
                // On close, Dismiss results and start capture session
                destination.dismiss(animated: true, completion: { [weak self] in
                    guard let `self` = self else {return}
                    if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
                        self.reStartCamera()
                    } else {
                        self.startCamera()
                    }
                })
            }
        }
    }
    
    // MARK: Class Functions
    func showCameraOrOnboarding() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.launchScreenExtension) { [weak self] in
            guard let `self` = self else {return}
            if self.isCameraUsageAuthorized() {
                self.showCamera()
            } else {
                self.showOnboarding()
            }
        }
    }
    
    func showCamera() {
        UpdateManager.shared.isUpdateAvailable { [weak self] shouldUpdate in
            guard let `self` = self else {return}
            if shouldUpdate {
                self.alert(title: Constants.Strings.shouldUpdate.title, message: Constants.Strings.shouldUpdate.message)
            }
        }
        if let onBoarding = self.view.viewWithTag(Constants.UI.onBoarding.tag) {
            onBoarding.removeFromSuperview()
        }
        self.reStartCamera()
    }
    
    func showOnboarding() {
        let onBoarding: OnBoardingView = OnBoardingView.fromNib()
        onBoarding.setup(in: self.view) { [weak self] in
            guard let `self` = self else {return}
            self.OnboardingButtonTapped()
        }
    }
    
    func OnboardingButtonTapped() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            askForCameraPermission {[weak self] allowed in
                guard let `self` = self else { return }
                if allowed {
                    self.showCamera()
                    return
                }
                self.alertCameraAccessIsNecessary()
            }
        } else if status == .denied {
            self.alertCameraAccessIsNecessary()
        } else {
            showCameraOrOnboarding()
        }
    }
    
    /// Show results of QR scan
    func found(card: ScanResultModel) {
        self.result = card
        self.performSegue(withIdentifier: Segues.showScanResult.rawValue, sender: self)
    }
    
    // MARK: Camera Permissions
    func isCameraUsageAuthorized()-> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined, .denied:
            return false
        case .restricted,.authorized:
            return true
        @unknown default:
            return false
        }
    }
    
    func askForCameraPermission(completion: @escaping(Bool)-> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {(granted: Bool) in
            DispatchQueue.main.async {
                return completion(granted)
            }
        })
    }
    
    func showCameraPermissionsSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            })
        }
    }
    
    func alertCameraAccessIsNecessary() {
        self.alert(title: Constants.Strings.Errors.CameraAccessIsNecessary.title, message: Constants.Strings.Errors.CameraAccessIsNecessary.message, completion: { [weak self] in
            guard let `self` = self else {return}
            self.showCameraPermissionsSettings()
        })
    }
    
    func removeCameraCutout() {
        let fillLayerName = Constants.UI.CameraView.CameraCutout.fillLayerName
        let bornerLayerName = Constants.UI.CameraView.CameraCutout.bornerLayerName
        let imageTag = Constants.UI.CameraView.CameraCutout.imageTag
        
        view.layer.sublayers?
            .filter { layer in return layer.name == fillLayerName }
            .forEach { layer in
                layer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        
        view.layer.sublayers?
            .filter { layer in return layer.name == bornerLayerName }
            .forEach { layer in
                layer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        
        if let existingImage = view.viewWithTag(imageTag) {
            existingImage.removeFromSuperview()
        }
        
        view.layer.layoutIfNeeded()
    }
    
    func addCameraCutout() {
        // Constants
        let fillLayerName = Constants.UI.CameraView.CameraCutout.fillLayerName
        let bornerLayerName = Constants.UI.CameraView.CameraCutout.bornerLayerName
        let imageTag = Constants.UI.CameraView.CameraCutout.imageTag
        
        let width: CGFloat = Constants.UI.CameraView.CameraCutout.width
        let height: CGFloat = Constants.UI.CameraView.CameraCutout.height
        let colour = Constants.UI.CameraView.CameraCutout.colour
        let opacity: Float = Constants.UI.CameraView.CameraCutout.opacity
        let cornerRadius: CGFloat = Constants.UI.CameraView.CameraCutout.cornerRadius
        
        let logoSize: CGFloat = Constants.UI.CameraView.CameraCutout.logoSize
        let paddingBetweenLogoAndBox: CGFloat = Constants.UI.CameraView.CameraCutout.paddingBetweenLogoAndBox
        
        self.removeCameraCutout()
        
        // positioning
        let horizontalDistance = (view.bounds.size.height - height) / 2
        let verticalDistance = (view.bounds.size.width - width) / 2
        
        // Outer
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
        // middle cutout
        let middlePart = UIBezierPath(roundedRect: CGRect(x: verticalDistance, y: horizontalDistance, width: width, height: height), cornerRadius: cornerRadius)
        path.append(middlePart)
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = colour
        fillLayer.opacity = opacity
        
        fillLayer.name = fillLayerName
        view.layer.addSublayer(fillLayer)
        
        // Add border
        let borderLayer = CAShapeLayer()
        let borderOuterPath = UIBezierPath(roundedRect: CGRect(x: verticalDistance, y: horizontalDistance, width: width, height: height), cornerRadius: cornerRadius)
        borderLayer.path = borderOuterPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 0.5
        
        borderLayer.name = bornerLayerName
        view.layer.addSublayer(borderLayer)
        
        // Add logo
        let logoImageView = UIImageView(frame: CGRect(x: verticalDistance, y: (horizontalDistance - logoSize) - paddingBetweenLogoAndBox, width: logoSize, height: logoSize))
        
        logoImageView.tag = imageTag
        view.addSubview(logoImageView)
        
        logoImageView.image = UIImage(named: "onCameraLogo")
    }
}

// MARK: Camera
extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    private func removeCameraPreview() {
        removeCameraCutout()
        if let existingPreview = self.previewLayer {
            existingPreview.removeFromSuperlayer()
            self.previewLayer = nil
        }
        
        if let existingSession = self.captureSession {
            existingSession.stopRunning()
            captureSession = nil
        }
        
        if let existingFlashButton = self.view.viewWithTag(Constants.UI.TorchButton.tag) {
            existingFlashButton.removeFromSuperview()
        }
    }
    // MARK: Setup
    private func setupCaptureSession() {
        
        removeCameraPreview()
        
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
            self.alert(title: Constants.Strings.Errors.VideoNotSupported.title,
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
            self.alert(title: Constants.Strings.Errors.QRScanningNotSupported.title,
                       message: Constants.Strings.Errors.QRScanningNotSupported.message)
            return
        }
        
        // Setup Preview
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = self.view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        preview.isAccessibilityElement = true
        preview.accessibilityLabel = AccessibilityLabels.scannerView.cameraView
        
        self.view.layer.addSublayer(preview)
        self.view.accessibilityLabel = AccessibilityLabels.scannerView.cameraView
        self.previewLayer = preview
        
        // Begin Capture Session
        captureSession.startRunning()
        
        addCameraCutout()
        
        // Set orientation
        guard let connection = preview.connection, connection.isVideoOrientationSupported, let orientation = windowInterfaceOrientation else {
            return
        }
        
        switch orientation {
        case .unknown:
            connection.videoOrientation = .portrait
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        @unknown default:
            connection.videoOrientation = .portrait
        }
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
            pauseCamera()
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
            // Validate QR code
            validate(code: stringValue)
        } else {
            // Show message
            self.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
        }
    }
    
    fileprivate func validate(code: String) {
        hideBanner()
        view.startLoadingIndicator()
        // Validate
        BCVaccineValidator.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {return}
            // Validation is done on background thread. This moves us back to main thread
            DispatchQueue.main.async {
                self.view.endLoadingIndicator()
                guard let data = result.result, result.status == .ValidCode else {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    // show an error & start camera
                    switch result.status {
                    case .ValidCode:
                        break
                    case .InvalidCode:
                        self.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    case .ForgedCode:
                        self.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    case .MissingData:
                        self.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    }
                    self.startCamera()
                    self.invalidScannedCodes.append(code)
                    return
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.found(card: data)
            }
        }
    }
    
    public func startCamera() {
        DispatchQueue.main.async {
            self.clearQRCodeLocations()
            self.captureSession?.startRunning()
        }
    }
    
    public func pauseCamera() {
        setFlash(on: false)
        captureSession?.stopRunning()
    }
    
    fileprivate func showMultipleQRCodesWarning(metadataObjects: [AVMetadataObject]) {
        for (index, item) in metadataObjects.enumerated() {
            showQRCodeLocation(for: item, isInValid: true, tag: 1000 + index)
        }
        showBanner(message: Constants.Strings.Errors.MultipleQRCodes.message)
    }
    
    fileprivate func showQRCodeLocation(for object: AVMetadataObject, isInValid: Bool, tag: Int) {
        guard let preview =  previewLayer, let metadataLocation = preview.transformedMetadataObject(for: object) else {
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
    
    func setFlash(on: Bool) {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
        
        guard let btn = self.view.viewWithTag(Constants.UI.TorchButton.tag) as? UIButton else {
            return
        }
        if on {
            btn.setImage(flashOnIcon, for: .normal)
            btn.accessibilityLabel = AccessibilityLabels.scannerView.turnOffFlash
        } else {
            btn.setImage(flashOffIcon, for: .normal)
            btn.accessibilityLabel = AccessibilityLabels.scannerView.turnOnFlash
        }
    }
    
    fileprivate func addFlashlightButton() {
        if let existing = self.view.viewWithTag(Constants.UI.TorchButton.tag) {
            existing.removeFromSuperview()
        }
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if !device.hasTorch && !device.hasFlash { return }
        
        let btnSize: CGFloat = Constants.UI.TorchButton.buttonSize
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        
        button.tag = Constants.UI.TorchButton.tag
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.backgroundColor = .lightGray
        button.setImage(flashOffIcon, for: .normal)
        button.accessibilityLabel = AccessibilityLabels.scannerView.turnOnFlash
        
        button.addTarget(self, action: #selector(flashTapped), for: .touchUpInside)
        button.layer.cornerRadius = btnSize/2
        
        button.imageView?.contentMode = .scaleAspectFit
    }
    
    @objc func flashTapped(sender: UIButton?) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let btn = self.view.viewWithTag(Constants.UI.TorchButton.tag) as? UIButton else {
            return
        }
        let isOn = btn.imageView?.image == flashOnIcon
        setFlash(on: !isOn)
    }
    
    
}
