package com.c0d3h01.androidtweaker.data

data class LogResult(val lines: List<String>, val missing: Boolean)

object LogTail {
    const val PATH = "/data/adb/modules/android_tweaker/tweaks.log"
    const val MAX_LINES = 200

    fun read(load: () -> String): LogResult =
        try {
            val lines = load().lineSequence()
                .map { it.trimEnd() }
                .filter { it.isNotEmpty() }
                .toList()
                .takeLast(MAX_LINES)
            LogResult(lines, missing = false)
        } catch (_: Exception) {
            LogResult(emptyList(), missing = true)
        }
}
