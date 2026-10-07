package com.c0d3h01.androidtweaker.data

interface ShellRunner {
    fun run(cmd: String): String
}

class ProfileRepository(private val runner: ShellRunner) {

    fun read(): Int? =
        runner.run("getprop persist.ainjector.profile").trim().toIntOrNull()

    fun write(code: Int) {
        runner.run("setprop persist.ainjector.profile $code")
    }

    fun switch(code: Int, maxPolls: Int = 3, sleep: (Long) -> Unit = { Thread.sleep(it) }): Boolean {
        write(code)
        repeat(maxPolls) {
            if (read() == code) return true
            sleep(3000)
        }
        return read() == code
    }
}
