package com.example.finance_tracker

import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "finance_tracker/ocr"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "recognizeText") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val path = call.arguments as? String
                if (path == null) {
                    result.error("invalid_image", "Image path is missing.", null)
                    return@setMethodCallHandler
                }

                try {
                    val image = InputImage.fromFilePath(this, path)
                    TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                        .process(image)
                        .addOnSuccessListener { result.success(it.text) }
                        .addOnFailureListener {
                            result.error("ocr_failed", it.localizedMessage, null)
                        }
                } catch (error: Exception) {
                    result.error("invalid_image", error.localizedMessage, null)
                }
            }
    }
}
