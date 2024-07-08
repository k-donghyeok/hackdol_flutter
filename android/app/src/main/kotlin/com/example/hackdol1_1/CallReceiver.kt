package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.telephony.TelephonyManager
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive called with action: ${intent.action}")

        val dataBuilder = Data.Builder()
        dataBuilder.putString("action", intent.action)
        dataBuilder.putString("state", intent.getStringExtra(TelephonyManager.EXTRA_STATE))
        dataBuilder.putString("incoming_number", intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER))

        val bundle = intent.extras
        if (bundle != null) {
            for (key in bundle.keySet()) {
                val value = bundle.get(key)
                when (value) {
                    is String -> dataBuilder.putString(key, value)
                    is Int -> dataBuilder.putInt(key, value)
                    is Boolean -> dataBuilder.putBoolean(key, value)
                    is Float -> dataBuilder.putFloat(key, value)
                    is Double -> dataBuilder.putDouble(key, value)
                    is Long -> dataBuilder.putLong(key, value)
                    else -> Log.d(TAG, "Unsupported bundle type for key $key")
                }
            }
        }

        val data = dataBuilder.build()

        val workRequest = OneTimeWorkRequest.Builder(CallReceiverWorker::class.java)
            .setInputData(data)
            .build()

        WorkManager.getInstance(context).enqueue(workRequest)
    }
}
