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
        val contentTitle = extras.getString(Notification.EXTRA_TITLE)
        val contentText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        Log.d(TAG, "Notification details - contentTitle: $contentTitle, contentText: $contentText")
        if ((contentTitle != null && contentTitle.contains("SMS")) || (contentText != null && contentText.contains("SMS"))) {
            // 메시지 앱의 알림이라면 처리
            val sender = extras.getString(Notification.EXTRA_TITLE)
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()

            Log.d(TAG, "Notification details - Sender: $sender, Text: $text")

            if (sender != null) {
                val blockedNumbers = BlockedNumbersManager.loadBlockedNumbers(this)
                // 차단된 번호에서 온 알림인지 확인
                if (blockedNumbers.contains(sender)) {
                    Log.d(TAG, "Ignoring notification from blocked sender: $sender")
                    cancelNotification(sbn.key)
                }
            }
        }
    }

}
