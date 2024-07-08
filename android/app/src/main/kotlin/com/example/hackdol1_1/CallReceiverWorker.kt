package com.example.hackdol1_1

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

class CallReceiverWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {
    private val TAG = "CallReceiverWorker"
    private val TAG4 = "CallReceiverWorker4"
    private val blockedNumbers: MutableList<String> = mutableListOf()

    override fun doWork(): Result {
        blockedNumbers.clear()
        blockedNumbers.addAll(BlockedNumbersManager.loadBlockedNumbers(applicationContext))

        try {
            val action = inputData.getString("action")
            if (action != null && action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
                val state = inputData.getString("state")
                if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                    val phoneNumber = inputData.getString("incoming_number")
                    Log.d(TAG4, "Incoming call: $phoneNumber")
                    Log.d(TAG4, "blockedNumbers: $blockedNumbers")
                    if (phoneNumber != null && blockedNumbers.contains(phoneNumber)) {
                        Log.d(TAG4, "Blocking call from $phoneNumber")
                        rejectCall()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing the broadcast", e)
            return Result.failure()
        }

        return Result.success()
    }

    private fun rejectCall() {
        val telephonyManager = applicationContext.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val telecomManager = applicationContext.getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            telecomManager.endCall()
        } else {
            try {
                val telephonyServiceClass = Class.forName(telephonyManager.javaClass.name)
                val methodEndCall = telephonyServiceClass.getDeclaredMethod("endCall")
                methodEndCall.isAccessible = true
                methodEndCall.invoke(telephonyManager)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
