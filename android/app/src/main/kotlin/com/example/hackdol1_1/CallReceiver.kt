package com.example.hackdol1_1

import android.app.Activity
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
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"
    private lateinit var interpreter: Interpreter
    private val blockedNumbers: MutableList<String> = mutableListOf()

    // 초기화 블록에서 TensorFlow Lite 모델 로드
    init {
        interpreter = Interpreter(loadModelFile(context))
    }

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

    // 스팸 예측 함수
    private fun predictSpam(message: String): Boolean {
        val inputBuffer = ByteBuffer.allocateDirect(256 * 4).apply { order(ByteOrder.nativeOrder()) }
        // 메시지 내용을 float 배열로 변환하고 입력 버퍼에 삽입
        val floatArray = messageToFloatArray(message)
        for (value in floatArray) {
            inputBuffer.putFloat(value)
        }
        val outputBuffer = ByteBuffer.allocateDirect(1 * 4).apply { order(ByteOrder.nativeOrder()) }
        interpreter.run(inputBuffer, outputBuffer)
        outputBuffer.rewind()
        return outputBuffer.float == 1.0f
    }

    private fun messageToFloatArray(message: String): FloatArray {
        // 메시지를 float 배열로 변환하는 로직을 여기에 구현
        // 예를 들어, 문자 메시지의 단어를 인덱스로 매핑하여 벡터화할 수 있습니다.
        // 이는 모델의 학습 과정에 따라 다릅니다.
        // 간단한 예시:
        val floatArray = FloatArray(256) { 0.0f }
        message.forEachIndexed { index, char ->
            if (index < 256) {
                floatArray[index] = char.toFloat()
            }
        }
        return floatArray
    }

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
                            // 스팸 예측
                            val isSpam = predictSpam(messageBody)
                            if (isSpam) {
                                Log.d(TAG, "Detected spam message from: $sender")
                                // 스팸 메시지를 무시
                                abortBroadcast()
                                return  // 메시지를 무시하고 메소드 종료
                            } else {
                                // 스팸이 아닌 경우에만 처리
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
