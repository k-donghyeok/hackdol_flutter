package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import android.util.Log
import java.lang.reflect.Method

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"

    // 차단된 전화번호 리스트
    private val blockedNumbers: MutableList<String> = mutableListOf()

    // 차단된 전화번호 설정
    fun setBlockedNumbers(numbers: List<String>) {
        blockedNumbers.clear()
        blockedNumbers.addAll(numbers)
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                // 전화가 왔을 때
                val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
                Log.d(TAG, "Incoming call: $phoneNumber")

                // 차단된 번호와 비교 후 거절 여부 결정
                if (phoneNumber != null && blockedNumbers.contains(phoneNumber)) {
                    Log.d(TAG, "Blocking call from $phoneNumber")
                    rejectCall(context)
                }
            }
        }
    }

    // 전화 거절 기능
    private fun rejectCall(context: Context) {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 이상에서는 TelecomManager를 사용하여 전화 거절
            telecomManager.endCall()

        } else {
            // Android 9 이하에서는 ITelephony를 사용하여 전화 거절
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