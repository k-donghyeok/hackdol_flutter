package com.example.hackdol1_1

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.*

class SmsReceiverWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {
    private val TAG = "SmsReceiverWorker"
    private val blockedNumbers: MutableList<String> = mutableListOf()
    private val blockedTexts: MutableList<String> = mutableListOf()

    override fun doWork(): Result {
        Log.d(TAG, "SmsReceiverWorker doWork called")

        blockedNumbers.clear()
        blockedNumbers.addAll(BlockedNumbersManager.loadBlockedNumbers(applicationContext))
        blockedTexts.clear()
        blockedTexts.addAll(BlockedTextManager.loadBlockedTexts(applicationContext))
        Log.d(TAG, "Blocked numbers loaded: $blockedNumbers")
        Log.d(TAG, "Blocked texts loaded: $blockedTexts")

        val action = inputData.getString("action")
        val message = inputData.getString("message")
        val sender = inputData.getString("sender")
        Log.d(TAG, "Action received: $action, message: $message, sender: $sender")

        if (action == "PREDICT_SPAM" && message != null && sender != null) {
            val isBlockedNumber = blockedNumbers.contains(sender)
            val isBlockedText = blockedTexts.any { message.contains(it) }

            if (!isBlockedNumber && !isBlockedText) {
                Log.d(TAG, "Sending message to server for prediction: $message from $sender")
                sendToServerForPrediction(message, sender)
            } else {
                val reason = when {
                    isBlockedNumber -> "차단된 번호"
                    isBlockedText -> "차단된 문구"
                    else -> "차단된 번호 또는 문구"
                }
                Log.d(TAG, "Ignoring SMS from blocked number or text: $sender")
                saveBlockedMessageToFirestore(sender, message, reason)
            }
        } else {
            Log.d(TAG, "Invalid action or missing message/sender")
        }
        return Result.success()
    }

    private fun sendToServerForPrediction(message: String, sender: String) {
        val client = OkHttpClient()

        val mediaType = "application/json; charset=utf-8".toMediaType()
        val jsonObject = JSONObject().put("message", message)
        val requestBody = jsonObject.toString().toRequestBody(mediaType)

        // Flask 서버의 IP 주소로 URL 변경
        val request = Request.Builder()
            .url("http://172.30.1.87:5000/predict") // 여기에 Flask 서버가 실행 중인 컴퓨터의 IP 주소를 사용합니다.
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                Log.e(TAG, "Error sending message to server for prediction", e)
            }

            override fun onResponse(call: Call, response: Response) {
                if (response.isSuccessful) {
                    response.body?.let { responseBody ->
                        val json = JSONObject(responseBody.string())
                        val isSpam = json.getBoolean("is_spam")
                        Log.d(TAG, "Prediction from server: $isSpam")

                        if (isSpam) {
                            saveBlockedMessageToFirestore(sender, message, "스팸 의심", "serverSubmissions")
                        }

                        // 메인 스레드에서 MethodChannel 호출
                        val mainHandler = Handler(Looper.getMainLooper())
                        mainHandler.post {
                            val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
                            if (flutterEngine != null) {
                                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.hackdol1_1/spam_detection_event").invokeMethod(
                                    "onSmsProcessed", mapOf(
                                        "message" to message,
                                        "isSpam" to isSpam.toString(),
                                        "sender" to sender
                                    )
                                )
                                Log.d(TAG, "srw에서 플러터 쪽으로 보냄: $message,$isSpam,$sender")
                            } else {
                                Log.e(TAG, "FlutterEngine not found in cache")
                            }
                        }
                    }
                } else {
                    Log.e(TAG, "Server returned error: ${response.code}")
                }
            }
        })
    }

    private fun saveBlockedMessageToFirestore(sender: String, message: String, reason: String, subCollection: String? = null) {
        val db = FirebaseFirestore.getInstance()
        val user = FirebaseAuth.getInstance().currentUser
        val uid = user?.uid ?: return

        val data = hashMapOf(
            "sender" to sender,
            "message" to message,
            "reportedAt" to Date(),
            "reason" to reason
        )

        val collection = if (subCollection == null) {
            db.collection("blockedMessages").document(uid).collection("messages")
        } else {
            db.collection("spamMessages").document(subCollection).collection(uid)
        }

        collection.add(data)
            .addOnSuccessListener { documentReference ->
                Log.d(TAG, "DocumentSnapshot added with ID: ${documentReference.id}")
            }
            .addOnFailureListener { e ->
                Log.w(TAG, "Error adding document", e)
            }
    }
}
