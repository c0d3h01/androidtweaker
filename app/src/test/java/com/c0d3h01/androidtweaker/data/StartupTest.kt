package com.c0d3h01.androidtweaker.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class StartupTest {

    @Test
    fun cachedValueShownWithoutShellCall() {
        var calls = 0
        val live: () -> Int? = { calls++; 4 }
        assertEquals(3, BootProfile.resolve(cached = 3, live = live))
        assertEquals(0, calls)
    }

    @Test
    fun fallsBackToLiveWhenNoCache() {
        assertEquals(4, BootProfile.resolve(cached = null, live = { 4 }))
        assertNull(BootProfile.resolve(cached = null, live = { null }))
    }

    @Test
    fun warmRunsOffCallingThread() {
        val latch = CountDownLatch(1)
        var sameThread = true
        BootProfile.warmAsync {
            sameThread = Thread.currentThread() === mainThread
            latch.countDown()
        }
        latch.await(5, TimeUnit.SECONDS)
        assertEquals(false, sameThread)
    }

    companion object {
        val mainThread: Thread = Thread.currentThread()
    }
}
