package com.example.hackdol1_1

import org.json.JSONObject

class CustomTokenizer(jsonObject: JSONObject) {
    private val wordIndex: Map<String, Int>

    init {
        val config = jsonObject.getJSONObject("config")
        val wordCountsString = config.getString("word_counts")
        val wordCounts = JSONObject(wordCountsString)
        val wordIndexMutable = mutableMapOf<String, Int>()
        wordCounts.keys().forEach {
            wordIndexMutable[it] = wordCounts.getInt(it)
        }
        wordIndex = wordIndexMutable.toMap()
    }

    fun textsToSequences(texts: List<String>): List<List<Int>> {
        return texts.map { text ->
            text.split(" ").mapNotNull { wordIndex[it] }
        }
    }
}
