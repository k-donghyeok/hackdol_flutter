package com.example.hackdol1_1

import android.content.Context
import android.util.Log
import org.json.JSONObject
import org.tensorflow.lite.Interpreter
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.Channels
import java.nio.charset.StandardCharsets

class ModelLoader(private val context: Context) {
    private val TAG = "ModelLoader"
    lateinit var interpreter: Interpreter
    lateinit var tokenizer: CustomTokenizer

    fun loadModelAndTokenizer(): Boolean {
        return try {
            // TFLite 모델 로드
            val assetManager = context.assets
            val modelInputStream = assetManager.open("converted_model.tflite")
            val modelBuffer = ByteBuffer.allocateDirect(modelInputStream.available()).order(ByteOrder.nativeOrder())
            Channels.newChannel(modelInputStream).read(modelBuffer)
            modelBuffer.rewind()

            val options = Interpreter.Options()
            options.setNumThreads(4)  // 스레드 수 설정
            interpreter = Interpreter(modelBuffer, options)
            interpreter.allocateTensors()
            Log.d(TAG, "Interpreter initialized successfully")

            // Tokenizer 로드
            val tokenizerInputStream = assetManager.open("tokenizer.json")
            val tokenizerJson = StandardCharsets.UTF_8.decode(ByteBuffer.wrap(tokenizerInputStream.readBytes())).toString()
            val jsonObject = JSONObject(tokenizerJson)
            tokenizer = CustomTokenizer(jsonObject)
            Log.d(TAG, "Tokenizer initialized successfully")

            true
        } catch (e: Exception) {
            Log.e(TAG, "Error loading TFLite model or tokenizer", e)
            false
        }
    }
}
