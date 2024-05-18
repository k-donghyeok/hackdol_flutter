package com.example.hackdol1_1

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class SMSNotificationListenerService : NotificationListenerService() {
    private val TAG = "SMSNotificationListener"

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)

        if (sbn.packageName == "com.android.messaging" || sbn.packageName == "com.google.android.apps.messaging") {
            val extras = sbn.notification.extras
            val title = extras.getString(Notification.EXTRA_TITLE)
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()

            Log.d(TAG, "Notification posted: $title - $text")

            if (title != null && text != null) {
                val blockedNumbers = BlockedNumbersManager.loadBlockedNumbers(this)
                if (blockedNumbers.any { text.contains(it) }) {
                    Log.d(TAG, "Ignoring notification from blocked sender: $title")
                    cancelNotification(sbn.key)
                }
            }
        }
    }
}
