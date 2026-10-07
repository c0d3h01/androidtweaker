package com.c0d3h01.androidtweaker.ui

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.c0d3h01.androidtweaker.data.Profile

@Composable
fun StatusRow(rootOk: Boolean?, profile: Profile?) {
    val dot = when (rootOk) {
        true -> "●"
        false -> "○"
        null -> "…"
    }
    Row {
        Text(dot, color = if (rootOk == true) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline)
        Spacer(Modifier.width(8.dp))
        Text(profile?.name?.lowercase()?.replaceFirstChar { it.uppercase() } ?: "Unknown")
    }
}
