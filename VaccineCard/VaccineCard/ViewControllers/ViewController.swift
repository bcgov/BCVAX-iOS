//
//  ViewController.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: Constants
    let flashOnIcon = UIImage(named: "flashOn")
    let flashOffIcon = UIImage(named: "flashOff")
    
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
    
    // MARK: Outlets
    @IBOutlet weak var onBoardContainer: UIView!
    @IBOutlet weak var onBoardTitle: UILabel!
    @IBOutlet weak var onBoardSubtitle: UILabel!
    @IBOutlet weak var onBoardButton: UIButton!
    
    enum Segues: String {
        case showScanResult = "showScanResult"
    }
    
    private var result: ScanResultModel? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.UI.Theme.primaryColor
        showCameraOrOnboarding()
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
    
    // MARK: Outlet Actions
    @IBAction func startScanningAction(_ sender: Any) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            askForCameraPermission {[weak self] allowed in
                guard let `self` = self else { return }
                if allowed {
                    self.showCameraOrOnboarding()
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
            // Set values on result controller
            destination.setup(model: result) { [weak self] in
                guard let `self` = self else {return}
                // On close, Dismiss results and start capture session
                destination.dismiss(animated: true, completion: { [weak self] in
                    guard let `self` = self else {return}
                    self.startCamera()
                })
            }
        }
    }
    
    // MARK: Class Functions
    func showCameraOrOnboarding() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {return}
            if self.isCameraUsageAuthorized() {
                self.setupCaptureSession()
                self.addFlashlightButton()
                self.onBoardContainer.alpha = 0
            } else {
                self.onBoardContainer.alpha = 1
                self.styleOnBoarding()
            }
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
            return completion(granted)
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
    
    // MARK: Styling
    func styleOnBoarding() {
        onBoardTitle.text = Constants.Strings.onBoarding.title
        onBoardTitle.font = Constants.Strings.onBoarding.titleFont
        onBoardSubtitle.text = Constants.Strings.onBoarding.subtitle
        onBoardSubtitle.font = Constants.Strings.onBoarding.subtitleFont
        onBoardButton.setTitle(Constants.Strings.onBoarding.buttonTitle, for: .normal)
        onBoardButton.backgroundColor = Constants.UI.Theme.primaryColor
        onBoardButton.setTitleColor(Constants.UI.Theme.primaryConstractColor, for: .normal)
        onBoardButton.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        if let titleLabel = onBoardButton.titleLabel {
            titleLabel.font = Constants.Strings.onBoarding.buttonFont
        }
    }
}

// MARK: Camera
extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
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
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = self.view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        
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
            pauseCamera()
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
            // Feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
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
        CodeValidationService.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {return}
            // Validation is done on background thread. This moves us back to main thread
            DispatchQueue.main.async {
                self.view.endLoadingIndicator()
                guard let data = result.result else {
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
                self.found(card: data)
            }
        }
    }
    
    public func startCamera() {
        clearQRCodeLocations()
        captureSession?.startRunning()
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
        
        // TODO: TAG FROM CONSTANT
        guard let btn = self.view.viewWithTag(92133) as? UIButton else {
            return
        }
        if on {
            btn.setImage(flashOnIcon, for: .normal)
        } else {
            btn.setImage(flashOffIcon, for: .normal)
        }
    }
    
    fileprivate func addFlashlightButton() {
        // TODO: Refactor constants
        let btnSize: CGFloat = 42
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        button.tag = 92133
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.backgroundColor = .lightGray
        button.setImage(flashOffIcon, for: .normal)
        
        button.addTarget(self, action: #selector(flashTapped), for: .touchUpInside)
        button.layer.cornerRadius = btnSize/2
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    @objc func flashTapped(sender: UIButton?) {
        // TODO: Refactor constants (Tag)
        guard let btn = self.view.viewWithTag(92133) as? UIButton else {
            return
        }
        let isOn = btn.imageView?.image == flashOnIcon
        if isOn {
            setFlash(on: false)
        } else {
            setFlash(on: true)
        }
    }
    
    
}
