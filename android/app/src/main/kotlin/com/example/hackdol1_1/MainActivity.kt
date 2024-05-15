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

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourapp/block_call"
    private val blockedNumbers: MutableList<String> = mutableListOf()

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

    private val callReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
                val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

                if (state == TelephonyManager.EXTRA_STATE_RINGING && incomingNumber != null) {
                    if (blockedNumbers.contains(incomingNumber)) {
                        val telephonyService = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                        try {
                            val method = telephonyService.javaClass.getDeclaredMethod("getITelephony")
                            method.isAccessible = true
                            val telephonyInterface = method.invoke(telephonyService)
                            val endCallMethod = telephonyInterface.javaClass.getDeclaredMethod("endCall")
                            endCallMethod.invoke(telephonyInterface)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }
            }
        }
    }
}
