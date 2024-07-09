package com.example.hackdol1_1

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity

open class FixFlutterActivity : FlutterFragmentActivity() {
    override fun onDestroy() {
        super.onDestroy()
        // Do not manually destroy the FlutterEngine here
    }

    companion object {
        fun createIntent(context: Context, initialRoute: String = "/"): Intent {
            return Intent(context, FixFlutterActivity::class.java)
                .putExtra("initial_route", initialRoute)
                .putExtra("background_mode", "opaque")
                .putExtra("destroy_engine_with_activity", true)
        }
    }
}
