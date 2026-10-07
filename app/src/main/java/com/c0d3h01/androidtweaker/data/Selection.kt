package com.c0d3h01.androidtweaker.data

import java.util.concurrent.atomic.AtomicInteger

/** Last-tap-wins arbiter for rapid profile taps. */
class TapArbiter {
    private val gen = AtomicInteger(0)

    fun tap(code: Int): Int {
        gen.incrementAndGet()
        return gen.get()
    }

    fun isLatest(token: Int): Boolean = token == gen.get()
}

/** Optimistic selection with revert-to-confirmed. -1 = unknown. */
class ProfileSelection(confirmed: Int) {
    var current: Int = confirmed
        private set
    private var baseline: Int = confirmed

    fun optimistic(code: Int) {
        current = code
    }

    fun confirm(code: Int) {
        baseline = code
        current = code
    }

    fun revert() {
        current = baseline
    }

    fun clear() {
        baseline = -1
        current = -1
    }
}
