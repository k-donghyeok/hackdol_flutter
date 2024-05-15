package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.hackdol1_1.CallReceiver

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourapp/block_call"
    private val blockedNumbers: MutableList<String> = mutableListOf()
    private val callReceiver = CallReceiver()
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateBlockedNumbers") {
                val numbers = call.arguments<List<String>>()!!
                blockedNumbers.clear()
                blockedNumbers.addAll(numbers)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        val filter = IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        registerReceiver(callReceiver, filter)
    }


}
