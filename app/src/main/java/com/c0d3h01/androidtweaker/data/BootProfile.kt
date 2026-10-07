package com.c0d3h01.androidtweaker.data

object BootProfile {
    fun resolve(cached: Int?, live: () -> Int?): Int? = cached ?: live()

    fun warmAsync(block: () -> Unit) {
        Thread(block).apply { isDaemon = true; start() }
    }
}
