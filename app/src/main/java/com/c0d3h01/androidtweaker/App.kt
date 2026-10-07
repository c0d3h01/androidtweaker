package com.c0d3h01.androidtweaker

import android.app.Application
import com.c0d3h01.androidtweaker.data.BootProfile
import com.c0d3h01.androidtweaker.util.RootShell
import com.c0d3h01.androidtweaker.util.SuProcessRunner

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        BootProfile.warmAsync {
            try {
                val runner = SuProcessRunner()
                runner.run("id")
                RootShell.install(runner)
            } catch (_: Exception) {
            }
        }
    }
}
