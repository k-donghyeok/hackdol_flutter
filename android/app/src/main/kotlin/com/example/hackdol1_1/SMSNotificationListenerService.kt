package com.example.hackdol1_1

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class SMSNotificationListenerService : NotificationListenerService() {
    private val TAG = "SMSNotificationListener"

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)

        // 메시지 앱의 알림인지 확인
        if (sbn.packageName == "com.android.messaging" || sbn.packageName == "com.google.android.apps.messaging") {
            val extras = sbn.notification.extras
            val sender = extras.getString(Notification.EXTRA_TITLE)
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()

            Log.d(TAG, "Notification posted: $sender - $text")

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
