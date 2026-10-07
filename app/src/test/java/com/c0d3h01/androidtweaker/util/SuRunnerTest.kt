package com.c0d3h01.androidtweaker.util

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.nio.file.Files

class SuRunnerTest {

    /** Fake `su`: executes stdin lines like a root shell. */
    private fun fakeSu(dieFirst: Boolean): String {
        val dir = Files.createTempDirectory("fakesu").toFile()
        val state = java.io.File(dir, "n").apply { writeText("0") }
        val su = java.io.File(dir, "su")
        val body = if (dieFirst) {
            "N=$(cat \"${state.absolutePath}\"); echo $((N+1)) > \"${state.absolutePath}\"\n" +
                "if [ \"${'$'}N\" = \"0\" ]; then read -r _; exit 1; fi\n"
        } else {
            ""
        }
        su.writeText("#!/bin/sh\n$body" + "while IFS= read -r line; do sh -c \"${'$'}line\"; done\n")
        su.setExecutable(true)
        return su.absolutePath
    }

    @Test
    fun framesOutputWithTrickyLines() {
        val r = SuProcessRunner(listOf(fakeSu(false)))
        val out = r.run("printf 'a\\n__AT_X__\\nb\\n'")
        assertTrue(out.contains("a"))
        assertTrue(out.contains("__AT_X__"))
        assertTrue(out.contains("b"))
    }

    @Test
    fun restartsDeadProcess() {
        val r = SuProcessRunner(listOf(fakeSu(true)))
        assertEquals("hello", r.run("echo hello").trim())
    }
}
