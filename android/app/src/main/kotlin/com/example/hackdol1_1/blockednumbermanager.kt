package com.example.hackdol1_1

import android.content.Context
import android.content.SharedPreferences

object BlockedNumbersManager {
    private const val PREFS_NAME = "blocked_numbers_prefs"
    private const val BLOCKED_NUMBERS_KEY = "blocked_numbers"

    fun saveBlockedNumbers(context: Context, blockedNumbers: List<String>) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putStringSet(BLOCKED_NUMBERS_KEY, blockedNumbers.toSet())
        editor.apply()
    }

    fun loadBlockedNumbers(context: Context): List<String> {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val blockedNumbersSet = prefs.getStringSet(BLOCKED_NUMBERS_KEY, emptySet())
        return blockedNumbersSet?.toList() ?: emptyList()
    }
}
