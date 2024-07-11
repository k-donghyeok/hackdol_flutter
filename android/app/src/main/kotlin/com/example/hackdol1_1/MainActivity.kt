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
import androidx.work.WorkManager
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.workDataOf
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FixFlutterActivity() {
    private val CHANNEL = "com.example.hackdol1_1/block_call"
    private val spam_CHANNEL = "com.example.hackdol1_1/spam_detection"
    private val text_CHANNEL = "com.example.hackdol1_1/block_text"
    private val ENGINE_ID = "my_engine_id"
    private val callReceiver = CallReceiver()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // FlutterEngine을 캐시에 저장
        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, text_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateBlockedTexts") {
                val texts = call.arguments<List<String>>()!!
                BlockedTextManager.saveBlockedTexts(this, texts)
                Log.d("MainActivity", "Blocked texts updated: $texts")
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
