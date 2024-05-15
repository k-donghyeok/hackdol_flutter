package com.example.hackdol1_1
import android.content.Context
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import java.lang.reflect.Method
import android.content.BroadcastReceiver
import android.content.Intent

class CallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                // 전화가 왔을 때 거절하는 로직을 호출합니다.
                rejectCall(context)
            }
        }
    }



    private fun rejectCall(context: Context) {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 11 이상에서는 TelecomManager를 사용하여 전화 거절
            telecomManager.endCall()
        } else {
            // Android 10 이하에서는 ITelephony를 사용하여 전화 거절
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
