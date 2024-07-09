package com.example.hackdol1_1

import android.Manifest
import android.app.AlertDialog
import android.content.BroadcastReceiver
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
import androidx.work.WorkManager
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.workDataOf
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
                Log.d("MainActivity", "Blocked numbers updated: $numbers")
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, spam_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isSpam") {
                val message = call.argument<String>("message")
                val sender = call.argument<String>("sender")
                if (message != null && sender != null) {
                    val data = workDataOf("action" to "PREDICT_SPAM", "message" to message, "sender" to sender)
                    val workRequest = OneTimeWorkRequestBuilder<SmsReceiverWorker>()
                        .setInputData(data)
                        .build()
                    WorkManager.getInstance(applicationContext).enqueue(workRequest)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "Message or Sender is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        checkAndRequestPermissions()

        val filter = IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        registerReceiver(callReceiver, filter)

        val smsFilter = IntentFilter("com.example.hackdol1_1.SMS_RECEIVED")
        registerReceiver(smsReceiver, smsFilter)

        if (!isNotificationServiceEnabled()) {
            showNotificationListenerDialog()
        }

        ignoreBatteryOptimization(this)
    }

    private fun checkAndRequestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.MODIFY_PHONE_STATE,
            Manifest.permission.ANSWER_PHONE_CALLS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.BIND_NOTIFICATION_LISTENER_SERVICE,
            Manifest.permission.SEND_SMS,
            Manifest.permission.READ_SMS
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
        unregisterReceiver(smsReceiver)
    }

    private val smsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.let {
                val message = it.getStringExtra("message")
                val isSpam = it.getBooleanExtra("isSpam", false)
                val sender = it.getStringExtra("sender")
                val arguments = mapOf("message" to message, "isSpam" to isSpam, "sender" to sender)
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, spam_CHANNEL)
                    .invokeMethod("smsReceived", arguments)
                Log.d("MainActivity", "메인액티비티에서 플러터쪽으로 전달: $message,$isSpam,$sender")
            }
        }
    }

    private fun ignoreBatteryOptimization(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent()
            val packageName = context.packageName
            val pm = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                intent.data = android.net.Uri.parse("package:$packageName")
                startActivity(intent)
            }
        }
    }
}
