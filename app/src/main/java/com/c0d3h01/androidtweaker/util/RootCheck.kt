package com.c0d3h01.androidtweaker.util

import com.c0d3h01.androidtweaker.data.ShellRunner

fun ShellRunner.isRoot(): Boolean =
    try {
        run("id").contains("uid=0")
    } catch (e: Exception) {
        false
    }
