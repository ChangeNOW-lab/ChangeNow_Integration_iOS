//
//  ScannerViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import AVFoundation
import SnapKit

protocol ScannerDelegate: AnyObject {

    func scannerFoundReadableCodeObject(value: String)
}

final class ScannerViewController: UIViewController {

    weak var delegate: ScannerDelegate?

    // MARK: - AVCapture

    private lazy var captureSession = AVCaptureSession()
    private lazy var metadataOutput = AVCaptureMetadataOutput()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()

    // MARK: - Views

    private lazy var blurView: UIView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.alpha = 0.8
        return view
    }()

    private lazy var maskFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.green.cgColor
        return layer
    }()
    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.addSublayer(maskFillLayer)
        return view
    }()

    private lazy var zoneImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.captureZone()
        view.tintColor = .primarySelection
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = .white
        view.font = .mediumDescription
        view.textAlignment = .center
        view.text = R.string.localizable.scannerDescription()
        return view
    }()

    private lazy var flashButton: DefaultButton = {
        let view = DefaultButton()
        view.extendedSize = 15
        view.setImage(R.image.flashDisabled(), for: .normal)
        view.setImage(R.image.flashEnabled(), for: .selected)
        view.addTarget(self, action: #selector(flashButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var cancelButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .regularHeader
        view.setTitleColor(.white, for: .normal)
        view.setTitle(R.string.localizable.cancel(), for: .normal)
        view.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return view
    }()

    private lazy var offsetViews: [UIView] = [UIView(), UIView(), UIView()]

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCaptureSession()
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        captureSession.startRunning()

        addSubviews()
        setConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer?.frame = view.layer.bounds
        metadataOutput.rectOfInterest = convertRectOfInterest(rect: zoneImageView.frame)
        updateBlurViewHole()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // MARK: - Private

    private func updateBlurViewHole() {
        let outerbezierPath = UIBezierPath(roundedRect: blurView.bounds, cornerRadius: 0)
        let innerCirclepath = UIBezierPath(roundedRect: zoneImageView.frame, cornerRadius: 10)
        outerbezierPath.append(innerCirclepath)
        outerbezierPath.usesEvenOddFillRule = true
        maskFillLayer.path = outerbezierPath.cgPath
    }

    private func addSubviews() {
        view.addSubview(blurView)
        view.addSubview(zoneImageView)
        view.addSubview(flashButton)
        view.addSubview(descriptionLabel)
        view.addSubview(cancelButton)
        blurView.mask = maskView
        for offsetView in offsetViews {
            view.addSubview(offsetView)
        }
    }

    private func setConstraints() {
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        zoneImageView.snp.makeConstraints {
            let topOffset = (view.bounds.size.height * 0.2).roundForUI()
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(topOffset)
            $0.size.equalTo(CGSize(width: 222, height: 222))
        }
        offsetViews[0].snp.makeConstraints {
            $0.top.equalTo(zoneImageView.snp.bottom)
            $0.centerX.leading.trailing.equalToSuperview()
        }
        flashButton.snp.makeConstraints {
            $0.top.equalTo(offsetViews[0].snp.bottom)
            $0.centerX.equalToSuperview()
        }
        offsetViews[1].snp.makeConstraints {
            $0.top.equalTo(flashButton.snp.bottom)
            $0.centerX.leading.trailing.equalToSuperview()
            $0.height.equalTo(offsetViews[0])
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(offsetViews[1].snp.bottom)
            $0.leadingMargin.trailingMargin.equalToSuperview()
        }
        offsetViews[2].snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom)
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top)
            $0.height.equalTo(offsetViews[1])
        }
        cancelButton.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            $0.height.equalTo(GlobalConsts.buttonHeight)
            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                $0.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-20)
            }
        }
    }

    private func configureCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
    }

    private func failed() {
        let alertVC = UIAlertController(title: R.string.localizable.scannerErrorTitle(),
                                        message: R.string.localizable.scannerErrorMessage(),
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default))
        present(alertVC, animated: true)
    }

    // MARK: - Actions

    @objc
    private func closeAction() {
        dismiss(animated: true)
    }

    @objc
    private func flashButtonAction() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch else {
                return
        }
        do {
            try device.lockForConfiguration()
            if device.torchMode == AVCaptureDevice.TorchMode.on {
                device.torchMode = AVCaptureDevice.TorchMode.off
                flashButton.isSelected = false
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    flashButton.isSelected = true
                } catch {
                    log.error(error.localizedDescription)
                }
            }
            device.unlockForConfiguration()
        } catch {
            log.error(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func convertRectOfInterest(rect: CGRect) -> CGRect {
        let screenRect = view.frame
        let screenWidth = screenRect.width
        let screenHeight = screenRect.height
        let newX = 1 / (screenWidth / rect.minX)
        let newY = 1 / (screenHeight / rect.minY)
        let newWidth = 1 / (screenWidth / rect.width)
        let newHeight = 1 / (screenHeight / rect.height)
        return CGRect(x: newY, y: newX, width: newHeight, height: newWidth)
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.scannerFoundReadableCodeObject(value: stringValue)
        }
        closeAction()
    }
}
