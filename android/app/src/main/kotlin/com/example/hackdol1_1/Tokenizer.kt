package com.example.hackdol1_1

import org.json.JSONObject

class Tokenizer(tokenizerJson: JSONObject) {
    private val wordIndex: Map<String, Int>

    init {
        val jsonObject = tokenizerJson.getJSONObject("word_index")
        wordIndex = jsonObject.keys().asSequence().associateWith { jsonObject.getInt(it) }
    }

    fun textsToSequences(texts: List<String>): List<List<Int>> {
        return texts.map { text ->
            text.split(" ").mapNotNull { wordIndex[it] }
        }
    }
}
