package com.c0d3h01.androidtweaker.util

import com.c0d3h01.androidtweaker.data.ShellRunner
import java.io.BufferedReader
import java.io.IOException
import java.util.UUID
import java.util.concurrent.atomic.AtomicInteger

/**
 * One persistent `su` process shared by the whole app. Commands run
 * sequentially under a lock, framed by a session-unique sentinel echo.
 * A dead process is restarted once per call. No per-call
 * `Runtime.exec("su")`, so the manager prompts at most once.
 */
class SuProcessRunner(private val command: List<String> = listOf("su")) : ShellRunner {
    private val lock = Any()
    private val seq = AtomicInteger(0)
    private val session = UUID.randomUUID().toString().take(8)
    private var process: Process? = null
    private var reader: BufferedReader? = null

    private fun ensureStarted() {
        if (process == null) {
            try {
                val p = ProcessBuilder(command).redirectErrorStream(true).start()
                process = p
                reader = p.inputStream.bufferedReader()
            } catch (e: IOException) {
                throw IllegalStateException("su not available", e)
            }
        }
    }

    private fun runOnce(cmd: String): String {
        ensureStarted()
        val p = process ?: throw IllegalStateException("su not available")
        val out = reader ?: throw IllegalStateException("su not available")
        val id = seq.incrementAndGet()
        val end = "__AT_${session}_${id}__"
        p.outputStream.write("$cmd\necho $end\n".toByteArray())
        p.outputStream.flush()
        val sb = StringBuilder()
        while (true) {
            val line = out.readLine() ?: throw IOException("su died")
            if (line == end) break
            sb.appendLine(line)
        }
        return sb.toString()
    }

    override fun run(cmd: String): String {
        synchronized(lock) {
            try {
                return runOnce(cmd)
            } catch (e: IOException) {
                process?.destroy()
                process = null
                reader = null
                return runOnce(cmd)
            }
        }
    }
}
