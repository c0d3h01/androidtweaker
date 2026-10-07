package com.c0d3h01.androidtweaker.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LogsTest {

    @Test
    fun missingLogReportsMissing() {
        val res = LogTail.read({ throw IllegalStateException("no su") })
        assertTrue(res.missing)
        assertEquals(0, res.lines.size)
    }

    @Test
    fun keepsOnlyLast200Lines() {
        val full = (1..500).joinToString("\n") { "line $it" }
        val res = LogTail.read({ full })
        assertFalse(res.missing)
        assertEquals(200, res.lines.size)
        assertEquals("line 301", res.lines.first())
        assertEquals("line 500", res.lines.last())
    }

    @Test
    fun shortLogPassesThrough() {
        val res = LogTail.read({ "a\nb\n" })
        assertEquals(listOf("a", "b"), res.lines)
    }
}
