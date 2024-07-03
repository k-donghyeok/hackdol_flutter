package com.example.hackdol1_1

import android.content.Context
import java.io.BufferedReader
import java.io.InputStreamReader

object MyFileUtil {
    fun loadJSONFromAsset(context: Context, fileName: String): String {
        val jsonString = StringBuilder()
        val reader = BufferedReader(InputStreamReader(context.assets.open(fileName)))

        reader.use {
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                jsonString.append(line)
            }
        }
        return jsonString.toString()
    }
}
