package com.example.hackdol1_1

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class SMSNotificationListenerService : NotificationListenerService() {
    private val TAG = "SMSNotificationListener"

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification listener connected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        Log.d(TAG, "Notification posted: ${sbn.packageName}")

        // 메시지 앱의 알림인지 확인
        val extras = sbn.notification.extras
        val sender = extras.getString(Notification.EXTRA_TITLE)
        val message = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        val senderNumber = sender?.replace(Regex("[^0-9]"), "")

        Log.d(TAG, "Notification details senderNumber: $senderNumber - Sender: $sender, Message: $message")

        if (sender != null) {
            val blockedNumbers = BlockedNumbersManager.loadBlockedNumbers(this).map { it.trim() }

            // 차단된 번호에서 온 알림인지 확인
            Log.d(TAG, "blockedNumbers: $blockedNumbers")
            if (blockedNumbers.contains(senderNumber)) {
                Log.d(TAG, "Ignoring notification from blocked sender: $senderNumber")
                cancelNotification(sbn.key)
                return
            }
        }
    }


}
