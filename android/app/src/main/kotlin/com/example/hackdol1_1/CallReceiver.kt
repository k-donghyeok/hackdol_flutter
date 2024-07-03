package com.example.hackdol1_1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.SmsMessage
import android.telephony.TelephonyManager
import android.util.Log
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.flex.FlexDelegate
import org.tensorflow.lite.support.common.FileUtil
import org.json.JSONObject
import java.io.FileNotFoundException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.StandardCharsets

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"
    private lateinit var interpreter: Interpreter
    private lateinit var tokenizer: Tokenizer
    private val blockedNumbers: MutableList<String> = mutableListOf()

    override fun onReceive(context: Context, intent: Intent) {
        blockedNumbers.clear()
        blockedNumbers.addAll(BlockedNumbersManager.loadBlockedNumbers(context))

        if (!::interpreter.isInitialized) {
            try {
                // FlexDelegate 초기화
                Log.d(TAG, "Initializing FlexDelegate")
                val delegate = FlexDelegate()
                val options = Interpreter.Options().addDelegate(delegate)

                // TFLite 모델 로드
                try {
                    val modelFile = FileUtil.loadMappedFile(context, "converted_model.tflite")
                    Log.d(TAG, "Model file loaded successfully")
                    interpreter = Interpreter(modelFile, options)
                    Log.d(TAG, "Interpreter initialized successfully")
                } catch (e: FileNotFoundException) {
                    Log.e(TAG, "Model file not found: ${e.message}")
                    return
                }

                // Tokenizer 로드
                try {
                    val tokenizerBuffer = FileUtil.loadMappedFile(context, "tokenizer.json")
                    val tokenizerJson = StandardCharsets.UTF_8.decode(tokenizerBuffer).toString()
                    Log.d(TAG, "Tokenizer file loaded successfully")
                    tokenizer = Tokenizer(JSONObject(tokenizerJson))
                    Log.d(TAG, "Tokenizer initialized successfully")
                } catch (e: FileNotFoundException) {
                    Log.e(TAG, "Tokenizer file not found: ${e.message}")
                    return
                }

            } catch (e: Exception) {
                Log.e(TAG, "Error loading TFLite model or tokenizer", e)
                return  // 모델 로딩 실패 시 return
            }
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
                        } else {
                            val isSpam = predictSpam(messageBody)
                            // Flutter로 메시지와 스팸 여부 전달
                            val broadcastIntent = Intent("com.example.hackdol1_1.SMS_RECEIVED")
                            broadcastIntent.putExtra("message", messageBody)
                            broadcastIntent.putExtra("isSpam", isSpam)
                            context.sendBroadcast(broadcastIntent)
                        }
                    }
                }
            }
        }
    }

    fun setBlockedNumbers(numbers: List<String>) {
        blockedNumbers.clear()
        blockedNumbers.addAll(numbers)
    }

    fun predictSpam(message: String): Boolean {
        // TFLite 모델 예측 로직 추가
        return try {
            val sequences = tokenizeAndPad(message)
            val inputBuffer = ByteBuffer.allocateDirect(4 * 100).order(ByteOrder.nativeOrder())
            inputBuffer.asFloatBuffer().put(sequences)

            val outputBuffer = ByteBuffer.allocateDirect(4).order(ByteOrder.nativeOrder())
            interpreter.run(inputBuffer, outputBuffer)

            val prediction = outputBuffer.asFloatBuffer().get(0)
            Log.d(TAG, "Prediction: $prediction")
            prediction > 0.5
        } catch (e: Exception) {
            Log.e(TAG, "Error during prediction", e)
            false
        }
    }

    private fun tokenizeAndPad(message: String): FloatArray {
        // 텍스트 토큰화 및 패딩 로직 추가
        val sequences = tokenizer.textsToSequences(listOf(message))[0]
        val padded = sequences.take(100).toMutableList()
        while (padded.size < 100) {
            padded.add(0)
        }
        return padded.map { it.toFloat() }.toFloatArray()
    }

    private fun rejectCall(context: Context) {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager

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
