package com.example.hackdol1_1

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.telephony.SmsMessage
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class SmsReceiverService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            if (it.action == "android.provider.Telephony.SMS_RECEIVED") {
                val bundle = it.extras
                if (bundle != null) {
                    val pdus = bundle.get("pdus") as Array<*>
                    val messages: MutableList<SmsMessage> = ArrayList()
                    for (pdu in pdus) {
                        val msg = SmsMessage.createFromPdu(pdu as ByteArray)
                        messages.add(msg)
                    }

                    for (message in messages) {
                        val sender = message.originatingAddress
                        val messageBody = message.messageBody
                        Log.d("SmsReceiverService", "Incoming SMS: $messageBody from $sender")

                        val data = Data.Builder()
                            .putString("action", "PREDICT_SPAM")
                            .putString("message", messageBody)
                            .putString("sender", sender)
                            .build()

                        val workRequest = OneTimeWorkRequestBuilder<SmsReceiverWorker>()
                            .setInputData(data)
                            .build()

                        Log.d("SmsReceiverService", "Enqueueing work request for message: $messageBody from $sender")
                        WorkManager.getInstance(this).enqueue(workRequest)
                    }
                }
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
