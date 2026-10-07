package com.c0d3h01.androidtweaker.data

enum class Profile(val code: Int) {
    BATTERY(1),
    BALANCED(2),
    PERFORMANCE(3),
    GAMING(4);

    companion object {
        fun fromCode(code: Int?): Profile? = entries.firstOrNull { it.code == code }
    }
}
