package com.example.hackdol1_1

import android.content.Context
import android.content.SharedPreferences

object BlockedTextManager {
    private const val PREFS_NAME = "blocked_texts_prefs"
    private const val BLOCKED_TEXTS_KEY = "blocked_texts"

    fun saveBlockedTexts(context: Context, blockedTexts: List<String>) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putStringSet(BLOCKED_TEXTS_KEY, blockedTexts.toSet())
        editor.apply()
    }

    fun loadBlockedTexts(context: Context): List<String> {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val blockedTextsSet = prefs.getStringSet(BLOCKED_TEXTS_KEY, emptySet())
        return blockedTextsSet?.toList() ?: emptyList()
    }
}
