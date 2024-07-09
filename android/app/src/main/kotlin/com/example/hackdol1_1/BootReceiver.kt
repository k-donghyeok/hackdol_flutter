package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Boot completed, starting services...")

            // SMSNotificationListenerService를 시작합니다.
            val serviceIntent = Intent(context, SMSNotificationListenerService::class.java)
            context.startService(serviceIntent)
        }
    }
}
