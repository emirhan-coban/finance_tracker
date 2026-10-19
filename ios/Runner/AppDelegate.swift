import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let channel = FlutterMethodChannel(
      name: "finance_tracker/ocr",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "recognizeText",
            let path = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.recognizeText(at: path, result: result)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func recognizeText(at path: String, result: @escaping FlutterResult) {
    guard let image = UIImage(contentsOfFile: path)?.cgImage else {
      result(FlutterError(code: "invalid_image", message: "Image could not be loaded.", details: nil))
      return
    }

    let request = VNRecognizeTextRequest { request, error in
      if let error {
        result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
        return
      }
      let text = (request.results as? [VNRecognizedTextObservation] ?? [])
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "\n")
      result(text)
    }
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["tr-TR", "en-US"]
    request.usesLanguageCorrection = true

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
      } catch {
        result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
