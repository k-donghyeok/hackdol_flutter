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

        val extras = sbn.notification.extras
        val sender = extras.getString(Notification.EXTRA_TITLE)
        val message = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        val senderNumber = sender?.replace(Regex("[^0-9]"), "")

        Log.d(TAG, "Notification details senderNumber: $senderNumber - Sender: $sender, Message: $message")




        // 차단된 전화번호 확인
        if (senderNumber != null) {
            val blockedNumbers = BlockedNumbersManager.loadBlockedNumbers(this).map { it.trim() }
            Log.d(TAG, "blockedNumbers: $blockedNumbers")

            if (blockedNumbers.contains(senderNumber)) {
                Log.d(TAG, "Ignoring notification from blocked sender: $senderNumber")
                cancelNotification(sbn.key)
                return
            }
        }

        // 차단된 문구 확인
        if (message != null) {
            val blockedTexts = BlockedTextManager.loadBlockedTexts(this)
            Log.d(TAG, "blockedTexts: $blockedTexts")

            for (blockedText in blockedTexts) {
                if (message.contains(blockedText)) {
                    Log.d(TAG, "Ignoring notification with blocked text: $blockedText")
                    cancelNotification(sbn.key)
                    return
                }
            }
        }

    }
}
