package com.example.hackdol1_1

import android.Manifest
import android.app.AlertDialog
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourapp/block_call"
    private val spam_CHANNEL = "com.example.hackdol1_1/spam_detection"
    private val callReceiver = CallReceiver()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateBlockedNumbers") {
                val numbers = call.arguments<List<String>>()!!
                BlockedNumbersManager.saveBlockedNumbers(this, numbers)
                callReceiver.setBlockedNumbers(BlockedNumbersManager.loadBlockedNumbers(this))

                Log.d("MainActivity", "Blocked numbers updated: $numbers")

                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, spam_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isSpam") {
                val message = call.argument<String>("message")
                if (message != null) {
                    val isSpam = callReceiver.predictSpam(message)
                    result.success(isSpam)
                } else {
                    result.error("INVALID_ARGUMENT", "Message is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        checkAndRequestPermissions()

        val filter = IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        filter.addAction("android.provider.Telephony.SMS_RECEIVED")
        registerReceiver(callReceiver, filter)

        if (!isNotificationServiceEnabled()) {
            showNotificationListenerDialog()
        }
    }

    private fun checkAndRequestPermissions() {
        val permissions = arrayOf(
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_CALL_LOG,
                Manifest.permission.CALL_PHONE,
                Manifest.permission.MODIFY_PHONE_STATE,
                Manifest.permission.ANSWER_PHONE_CALLS,
                Manifest.permission.RECEIVE_SMS,
        )

        val permissionsToRequest = permissions.filter {
            ActivityCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), 1)
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(ComponentName(this, SMSNotificationListenerService::class.java.name).flattenToString())
    }

    private fun showNotificationListenerDialog() {
        AlertDialog.Builder(this)
                .setTitle("Notification Listener Service")
                .setMessage("차단된 번호의 SMS 알림을 차단하려면 알림 수신 서비스를 활성화하세요.")
                .setPositiveButton("Enable") { _, _ ->
                    startActivityForResult(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS), 1001)
                }
                .setNegativeButton("Cancel", null)
                .show()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1001 && !isNotificationServiceEnabled()) {
            showNotificationListenerDialog()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(callReceiver)
    }
}
