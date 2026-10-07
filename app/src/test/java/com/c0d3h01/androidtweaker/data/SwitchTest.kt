package com.c0d3h01.androidtweaker.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SwitchTest {

    @Test
    fun confirmsOnSecondPoll() {
        val fake = ScriptRunner(mutableListOf("3", "4"))
        val repo = ProfileRepository(fake)
        assertTrue(repo.switch(4, maxPolls = 3, sleep = {}))
        assertEquals("setprop persist.ainjector.profile 4", fake.writes.last())
    }

    @Test
    fun returnsFalseWhenNeverConfirms() {
        val fake = ScriptRunner(mutableListOf("3", "3", "3"))
        val repo = ProfileRepository(fake)
        assertFalse(repo.switch(4, maxPolls = 3, sleep = {}))
        assertEquals(1, fake.writes.size)
    }

    @Test
    fun lastWriteWins() {
        val fake = ScriptRunner(mutableListOf("4", "2"))
        val repo = ProfileRepository(fake)
        repo.switch(4, maxPolls = 1, sleep = {})
        repo.switch(2, maxPolls = 1, sleep = {})
        assertEquals("setprop persist.ainjector.profile 2", fake.writes.last())
    }

    private class ScriptRunner(private val reads: MutableList<String>) : ShellRunner {
        val writes = mutableListOf<String>()
        override fun run(cmd: String): String {
            if (cmd.startsWith("setprop")) writes.add(cmd)
            return if (cmd.startsWith("getprop")) reads.removeFirstOrNull() ?: "" else ""
        }
    }
}
