package com.c0d3h01.androidtweaker

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.c0d3h01.androidtweaker.data.BootProfile
import com.c0d3h01.androidtweaker.data.LogTail
import com.c0d3h01.androidtweaker.data.Profile
import com.c0d3h01.androidtweaker.data.ProfileRepository
import com.c0d3h01.androidtweaker.data.ProfileSelection
import com.c0d3h01.androidtweaker.data.TapArbiter
import com.c0d3h01.androidtweaker.ui.LogsScreen
import com.c0d3h01.androidtweaker.ui.StatusRow
import com.c0d3h01.androidtweaker.util.RootShell
import com.c0d3h01.androidtweaker.util.SuProcessRunner
import com.c0d3h01.androidtweaker.util.isRoot

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val prefs = getSharedPreferences("profile", MODE_PRIVATE)
        val cached = prefs.getString("profile", null)?.toIntOrNull()
        setContent {
            MaterialTheme {
                HomeScreen(
                    cachedCode = cached,
                    onSelected = { code ->
                        prefs.edit().putString("profile", code.toString()).apply()
                    },
                    onCleared = {
                        prefs.edit().remove("profile").apply()
                    }
                )
            }
        }
    }
}

private data class Card(val profile: Profile, val title: Int, val desc: Int)

private val CARDS = listOf(
    Card(Profile.BATTERY, R.string.prof_battery, R.string.pdesc_battery),
    Card(Profile.BALANCED, R.string.prof_balanced, R.string.pdesc_balanced),
    Card(Profile.PERFORMANCE, R.string.prof_performance, R.string.pdesc_performance),
    Card(Profile.GAMING, R.string.prof_gaming, R.string.pdesc_gaming),
)

@Composable
fun HomeScreen(cachedCode: Int?, onSelected: (Int) -> Unit, onCleared: () -> Unit) {
    val selection = remember { ProfileSelection(cachedCode ?: -1) }
    val arbiter = remember { TapArbiter() }
    val uiHandler = remember { Handler(Looper.getMainLooper()) }
    val context = LocalContext.current
    var current by remember { mutableIntStateOf(selection.current) }
    var noRoot by remember { mutableStateOf(false) }
    var noSpec by remember { mutableStateOf(false) }
    var rootOk by remember { mutableStateOf<Boolean?>(null) }
    var tab by remember { mutableIntStateOf(0) }
    var logLines by remember { mutableStateOf(listOf<String>()) }
    var logMissing by remember { mutableStateOf(false) }
    val lifecycle = LocalLifecycleOwner.current.lifecycle

    fun onUi(block: () -> Unit) = uiHandler.post(block)
    fun sync() = onUi { current = selection.current }
    fun toast(msg: String) = onUi {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
    }

    fun loadLogs() {
        BootProfile.warmAsync {
            val res = try {
                LogTail.read({ RootShell.runner().run("tail -n 200 ${LogTail.PATH}") })
            } catch (_: Exception) {
                LogTail.read({ throw IllegalStateException("no shell") })
            }
            onUi {
                logLines = res.lines
                logMissing = res.missing
            }
        }
    }

    fun refresh() {
        BootProfile.warmAsync {
            val repo = try {
                ProfileRepository(RootShell.runner())
            } catch (_: Exception) {
                try {
                    val r = SuProcessRunner()
                    RootShell.install(r)
                    ProfileRepository(r)
                } catch (_: Exception) {
                    onUi { noRoot = true; rootOk = false }
                    return@warmAsync
                }
            }
            if (!RootShell.runner().isRoot()) {
                onUi { noRoot = true; rootOk = false }
                return@warmAsync
            }
            onUi { rootOk = true }
            val code = repo.read()
            if (code == null) {
                selection.clear()
                sync()
                onUi { noSpec = true }
                onCleared()
                return@warmAsync
            }
            selection.confirm(code)
            sync()
        }
    }

    DisposableEffect(lifecycle) {
        val obs = LifecycleEventObserver { _, e ->
            if (e == Lifecycle.Event.ON_RESUME) refresh()
        }
        lifecycle.addObserver(obs)
        onDispose { lifecycle.removeObserver(obs) }
    }

    Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("AndroidTweaker", style = MaterialTheme.typography.headlineSmall)
        StatusRow(rootOk = rootOk, profile = Profile.fromCode(current))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            TextButton(onClick = { tab = 0 }) { Text("Profiles") }
            TextButton(onClick = { tab = 1; loadLogs() }) { Text("Logs") }
        }
        if (tab == 1) {
            LogsScreen(lines = logLines, missing = logMissing)
            return@Column
        }
        LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            items(CARDS) { card ->
                val selected = current == card.profile.code
                Card(
                    colors = if (selected) CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                    else CardDefaults.cardColors(),
                    modifier = Modifier.fillMaxWidth().clickable {
                        val token = arbiter.tap(card.profile.code)
                        selection.optimistic(card.profile.code)
                        sync()
                        onSelected(card.profile.code)
                        BootProfile.warmAsync {
                            val ok = try {
                                ProfileRepository(RootShell.runner())
                                    .switch(card.profile.code, sleep = { Thread.sleep(it) })
                            } catch (_: Exception) {
                                false
                            }
                            if (!arbiter.isLatest(token)) return@warmAsync
                            if (ok) {
                                selection.confirm(card.profile.code)
                                sync()
                            } else {
                                selection.revert()
                                sync()
                                if (rootOk == false) onUi { noRoot = true }
                                else toast("Switch failed — reverted")
                            }
                        }
                    }
                ) {
                    Column(Modifier.padding(16.dp)) {
                        Text(stringResource(card.title), style = MaterialTheme.typography.titleLarge)
                        Text(stringResource(card.desc), style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }
    }

    if (noRoot) AlertDialog(
        onDismissRequest = {},
        confirmButton = { TextButton(onClick = { noRoot = false }) { Text("OK") } },
        text = { Text(stringResource(R.string.noroot)) }
    )
    if (noSpec) AlertDialog(
        onDismissRequest = {},
        confirmButton = { TextButton(onClick = { noSpec = false }) { Text("OK") } },
        text = { Text(stringResource(R.string.nospec)) }
    )
}
