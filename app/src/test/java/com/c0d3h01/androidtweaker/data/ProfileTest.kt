package com.c0d3h01.androidtweaker.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ProfileTest {

    @Test
    fun mapsAll() {
        assertEquals(Profile.BATTERY, Profile.fromCode(1))
        assertEquals(Profile.BALANCED, Profile.fromCode(2))
        assertEquals(Profile.PERFORMANCE, Profile.fromCode(3))
        assertEquals(Profile.GAMING, Profile.fromCode(4))
    }

    @Test
    fun unknownIsNull() {
        assertNull(Profile.fromCode(0))
        assertNull(Profile.fromCode(5))
        assertNull(Profile.fromCode(9))
        assertNull(Profile.fromCode(null))
    }

    @Test
    fun readParsesGetprop() {
        val repo = ProfileRepository(FakeRunner("3\n"))
        assertEquals(3, repo.read())
    }

    @Test
    fun readReturnsRawCode() {
        assertEquals(null, ProfileRepository(FakeRunner("")).read())
        assertEquals(null, ProfileRepository(FakeRunner("garbage\n")).read())
        assertEquals(1, ProfileRepository(FakeRunner("1\n")).read())
        assertEquals(3, ProfileRepository(FakeRunner("  3  \n")).read())
    }

    @Test
    fun writeSendsExactSetprop() {
        val fake = FakeRunner("")
        ProfileRepository(fake).write(4)
        assertEquals("setprop persist.ainjector.profile 4", fake.lastCmd)
    }

    private class FakeRunner(var out: String) : ShellRunner {
        var lastCmd: String? = null
        override fun run(cmd: String): String {
            lastCmd = cmd
            return out
        }
    }
}
