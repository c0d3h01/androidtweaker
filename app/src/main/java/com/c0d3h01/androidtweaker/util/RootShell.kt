package com.c0d3h01.androidtweaker.util

import com.c0d3h01.androidtweaker.data.ShellRunner

/**
 * Single persistent root shell. The platform adapter (libsu, Task 3)
 * registers once via [install]; all callers share it. Unit tests install
 * a fake. Debounce (800ms, last-tap-wins) is enforced by the UI layer.
 */
object RootShell {
    private var runner: ShellRunner? = null

    fun install(runner: ShellRunner) {
        this.runner = runner
    }

    fun runner(): ShellRunner =
        runner ?: throw IllegalStateException("RootShell not installed")
}
