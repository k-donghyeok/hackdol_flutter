package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.SmsMessage
import android.telephony.TelephonyManager
import android.util.Log

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
        // Broadcast를 받을 때마다 차단된 번호를 로드
        blockedNumbers.clear()
        blockedNumbers.addAll(BlockedNumbersManager.loadBlockedNumbers(context))

        when (intent.action) {
            TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {
                val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                    // 전화가 왔을 때
                    val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
                    Log.d(TAG, "Incoming call: $phoneNumber")
                    Log.d(TAG, "blocknumbers: $blockedNumbers")
                    // 차단된 번호와 비교 후 거절 여부 결정
                    if (phoneNumber != null && blockedNumbers.contains(phoneNumber)) {
                        Log.d(TAG, "Blocking call from $phoneNumber")
                        rejectCall(context)
                    }
                }
            }
            "android.provider.Telephony.SMS_RECEIVED" -> {
                // 문자 메시지가 도착했을 때
                val bundle = intent.extras
                if (bundle != null) {
                    val pdus = bundle.get("pdus") as Array<Any>
                    for (pdu in pdus) {
                        val smsMessage = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            SmsMessage.createFromPdu(pdu as ByteArray, bundle.getString("format"))
                        } else {
                            SmsMessage.createFromPdu(pdu as ByteArray)
                        }
                        val messageBody = smsMessage.messageBody
                        val sender = smsMessage.originatingAddress
                        Log.d(TAG, "Incoming SMS: $messageBody from $sender")
                        Log.d(TAG, "blocknumbers: $blockedNumbers")
                        // 차단된 번호인 경우 메시지를 무시
                        if (sender != null && blockedNumbers.contains(sender)) {
                            Log.d(TAG, "Ignoring SMS from blocked number: $sender")
                            // 문자 메시지를 브로드캐스트 중지
                            abortBroadcast()
                            return  // 메시지를 무시하고 메소드 종료
                        } else if (sender != null) {
                            // 차단된 번호가 아닌 경우에만 처리
                            val intent = Intent("com.example.hackdol1_1.SMS_RECEIVED")
                            intent.putExtra("message", messageBody)
                            context.sendBroadcast(intent)
                        }
                    }
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
