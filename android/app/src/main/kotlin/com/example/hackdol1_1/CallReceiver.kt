package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.res.AssetFileDescriptor
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.SmsMessage
import android.telephony.TelephonyManager
import android.util.Log
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import org.tensorflow.lite.DataType
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel
import java.util.*

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"
    private lateinit var interpreter: Interpreter
    private val blockedNumbers: MutableList<String> = mutableListOf()
    private val maxLen = 256  // Define maxLen as a class property

    // TensorFlow Lite 모델 로드 함수
    private fun loadModelFile(context: Context): ByteBuffer {
        val assetFileDescriptor: AssetFileDescriptor = context.assets.openFd("spam_model.tflite")
        val inputStream = assetFileDescriptor.createInputStream()
        val fileChannel = inputStream.channel
        val startOffset = assetFileDescriptor.startOffset
        val declaredLength = assetFileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength).apply {
            order(ByteOrder.nativeOrder())
        }
    }

    // 메시지 전처리 함수
    private fun preprocessMessage(message: String, maxLen: Int): FloatArray {
        val input = FloatArray(maxLen) { 0.0f }
        val words = message.split(" ")
        for (i in words.indices) {
            if (i < maxLen) {
                input[i] = words[i].hashCode().toFloat()
            }
        }
        return input
    }

    // 스팸 예측 함수
    fun predictSpam(message: String): Boolean {
        val inputBuffer = TensorBuffer.createFixedSize(intArrayOf(1, maxLen), DataType.FLOAT32)
        val inputData = preprocessMessage(message, maxLen)
        inputBuffer.loadArray(inputData)

        val outputBuffer = TensorBuffer.createFixedSize(intArrayOf(1, 1), DataType.FLOAT32)
        interpreter.run(inputBuffer.buffer, outputBuffer.buffer)

        return outputBuffer.floatArray[0] > 0.5
    }

    // 차단된 전화번호 설정
    fun setBlockedNumbers(numbers: List<String>) {
        blockedNumbers.clear()
        blockedNumbers.addAll(numbers)
    }

    override fun onReceive(context: Context, intent: Intent) {
        blockedNumbers.clear()
        blockedNumbers.addAll(BlockedNumbersManager.loadBlockedNumbers(context))

        if (!::interpreter.isInitialized) {
            interpreter = Interpreter(loadModelFile(context))
        }

        when (intent.action) {
            TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {
                val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                    val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
                    Log.d(TAG, "Incoming call: $phoneNumber")
                    Log.d(TAG, "blocknumbers: $blockedNumbers")
                    if (phoneNumber != null && blockedNumbers.contains(phoneNumber)) {
                        Log.d(TAG, "Blocking call from $phoneNumber")
                        rejectCall(context)
                    }
                }
            }
            "android.provider.Telephony.SMS_RECEIVED" -> {
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
                        if (sender != null && blockedNumbers.contains(sender)) {
                            Log.d(TAG, "Ignoring SMS from blocked number: $sender")
                            abortBroadcast()
                            return
                        } else if (sender != null) {
                            val isSpam = predictSpam(messageBody)
                            if (isSpam) {
                                Log.d(TAG, "Detected spam message from: $sender")
                                abortBroadcast()
                                return
                            } else {
                                val intent = Intent("com.example.hackdol1_1.SMS_RECEIVED")
                                intent.putExtra("message", messageBody)
                                context.sendBroadcast(intent)
                            }
                        }
                    }
                }
            }
        }
    }

    private fun rejectCall(context: Context) {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
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
