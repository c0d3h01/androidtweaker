package com.c0d3h01.androidtweaker.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ArbiterTest {

    @Test
    fun lastTapWins() {
        val arbiter = TapArbiter()
        val first = arbiter.tap(4)
        val second = arbiter.tap(2)
        assertFalse(arbiter.isLatest(first))
        assertTrue(arbiter.isLatest(second))
    }

    @Test
    fun selectionRevertsToLastConfirmed() {
        val sel = ProfileSelection(confirmed = 3)
        sel.optimistic(5)
        assertEquals(5, sel.current)
        sel.revert()
        assertEquals(3, sel.current)
    }

    @Test
    fun selectionConfirmMovesBaseline() {
        val sel = ProfileSelection(confirmed = 3)
        sel.optimistic(5)
        sel.confirm(5)
        sel.optimistic(2)
        sel.revert()
        assertEquals(5, sel.current)
    }

    @Test
    fun selectionClearShowsUnknown() {
        val sel = ProfileSelection(confirmed = 3)
        sel.clear()
        assertEquals(-1, sel.current)
    }
}
