package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class SmsBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("SmsBroadcastReceiver", "onReceive called with action: ${intent.action}")
        if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
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
                    Log.d("SmsBroadcastReceiver", "Incoming SMS: $messageBody from $sender")

                    val data = Data.Builder()
                        .putString("action", "PREDICT_SPAM")
                        .putString("message", messageBody)
                        .putString("sender", sender)
                        .build()

                    val workRequest = OneTimeWorkRequestBuilder<SmsReceiverWorker>()
                        .setInputData(data)
                        .build()

                    Log.d("SmsBroadcastReceiver", "Enqueueing work request for message: $messageBody from $sender")
                    WorkManager.getInstance(context).enqueue(workRequest)
                }
            }
        }
    }
}
