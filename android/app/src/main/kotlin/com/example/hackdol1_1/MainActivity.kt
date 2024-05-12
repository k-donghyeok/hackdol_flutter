package com.example.hackdol1_1

import com.example.BlockPhoneNumberHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val methodChannel =
            MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        methodChannel.setMethodCallHandler(
            BlockPhoneNumberHandler(
                getContentResolver()
            )
        )
    }

    companion object {
        private const val CHANNEL = "com.example.block_phone_number"
    }
}

