package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf

class SmsBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null && intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle: Bundle? = intent.extras
            try {
                if (bundle != null) {
                    val pdusObj = bundle["pdus"] as Array<*>
                    for (i in pdusObj.indices) {
                        val currentMessage = SmsMessage.createFromPdu(pdusObj[i] as ByteArray)
                        val phoneNumber: String = currentMessage.displayOriginatingAddress
                        val message: String = currentMessage.displayMessageBody

                        Log.d("SmsBroadcastReceiver", "Sender: $phoneNumber; Message: $message")

                        val data = workDataOf(
                            "action" to "PREDICT_SPAM",
                            "message" to message,
                            "sender" to phoneNumber
                        )
                        val workRequest = OneTimeWorkRequestBuilder<SmsReceiverWorker>()
                            .setInputData(data)
                            .build()
                        WorkManager.getInstance(context!!).enqueue(workRequest)
                    }
                }
            } catch (e: Exception) {
                Log.e("SmsBroadcastReceiver", "Exception smsReceiver", e)
            }
        }
    }
}
