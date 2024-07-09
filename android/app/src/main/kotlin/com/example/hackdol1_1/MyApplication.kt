package com.example.hackdol1_1

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.FlutterJNI
import android.util.Log

class MyApplication : Application() {
    lateinit var flutterEngine: FlutterEngine
    private val flutterJNI = FlutterJNI()

    override fun onCreate() {
        super.onCreate()
        Log.d("MyApplication", "onCreate called")

        // FlutterEngine 초기화 및 캐시에 저장
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine)
        flutterJNI.attachToNative()

        Log.d("MyApplication", "FlutterEngine initialized and cached: $flutterEngine")
    }
}
