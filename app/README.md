# AndroidTweaker — Companion App

Companion app for the AndroidTweaker root module. Pick a profile once —
the module applies it at boot and every time you switch. No reboot needed.

- Package: `com.c0d3h01.androidtweaker`
- Stack: Kotlin, single-activity, Compose Material3, no root libraries
  (one persistent `su` process via stdlib `ProcessBuilder`)
- minSdk 26, targetSdk / compileSdk 34
- Release APK ≈ 1 MB (R8 + `shrinkResources`)

## Requirements

- Android 8.0 (API 26) or higher
- Root: Magisk v20.4+, KernelSU v0.6.6+, or APatch
- Flashed AndroidTweaker module (the app is useless without its daemon)
- Build machine: JDK 17 and Gradle 9.2 (see Building)

## Features

| Screen   | What it does                                                              |
| -------- | ------------------------------------------------------------------------- |
| Profiles | 4 cards — Battery (1), Balanced (2), Performance (3), Gaming (4). Tap to apply. |
| Status   | Root grant dot + current profile label, re-read on every resume.          |
| Logs     | Last 200 lines of the module log, with empty-state when missing.          |

Switch behavior: optimistic highlight → `setprop persist.ainjector.profile <n>`
→ poll `getprop` (max 3 × 3 s). Last tap wins; failure reverts to the last
confirmed profile with a toast. Unknown/empty prop shows Unknown and never
writes (`1` is the daemon's legacy no-op — not an error).

## Project structure

```
app/
├── build.gradle.kts            # app module (R8 + shrinkResources in release)
├── proguard-rules.pro
└── src/
    ├── main/
    │   ├── AndroidManifest.xml # launcher activity, adaptive icon
    │   ├── java/com/c0d3h01/androidtweaker/
    │   │   ├── App.kt                  # warms root shell off the main thread
    │   │   ├── MainActivity.kt         # Compose Home: cards, tabs, dialogs
    │   │   ├── data/
    │   │   │   ├── Profile.kt          # BATTERY(2) BALANCED(3) PERFORMANCE(4) GAMING(5)
    │   │   │   ├── ProfileRepository.kt# read/write/switch over a ShellRunner
    │   │   │   ├── Selection.kt        # TapArbiter (last-wins) + ProfileSelection
    │   │   │   ├── BootProfile.kt      # cache-first resolve + bg warm helper
    │   │   │   └── LogTail.kt          # bounded log tail (200 lines)
    │   │   └── util/
    │   │       ├── SuProcessRunner.kt  # single persistent `su`, restart on death
    │   │       ├── RootShell.kt        # shared shell registry
    │   │       └── RootCheck.kt        # `id` contains `uid=0`
    │   └── res/                        # strings, adaptive icon, colors
    └── test/                           # 20 JVM unit tests (6 files)
```

## Building

Gradle 9.2 with AGP 8.13 requires JDK 17 (newer JDKs break the build).
Set `JAVA_HOME` to JDK 17 first — per-OS paths are in the repo `CONTRIBUTING.md`.
`./gradlew` (pinned 9.2.0) is preferred over a system Gradle:

```bash
./gradlew :app:testDebugUnitTest   # 20 unit tests
./gradlew :app:assembleDebug       # debug APK
./gradlew :app:stageReleaseApk     # signed release → app/release/androidtweaker.apk
```

## Release packaging

`stageReleaseApk` builds a signed release and stages it at
`app/release/androidtweaker.apk` — the file the module installs
(`service.sh` → `pm install -r -g`, then deletes it from the zip):

```bash
<gradle-9.2>/bin/gradle :app:stageReleaseApk
# pack app/release/androidtweaker.apk at the module zip root as AndroidTweaker.apk
```

Signing: release uses the shared dev key in `app/release.keystore`, configured
by the committed `app/release.properties` (machine-local overrides go in the
ignored root `local.properties`). Any developer can build an installable
release with `:app:stageReleaseApk` — which is exactly why this repo must
stay access-controlled: anyone with read access can ship updates as this
app, and the root grant follows the certificate. Never change the keystore;
rotation forces every user to uninstall/reinstall.

`module.prop:companionPkg` must match this app's `applicationId`.
`service.sh` removes the legacy `beastmode.profile` package once on upgrade.

## Root permission persistence

The grant lives in the root manager (Magisk/KernelSU/APatch), keyed by
package name + signing certificate — not in this app. So:

- One grant sticks forever **as long as the package name and release
  signing key never change**. Rotate neither.
- Grant with "Remember"/"Allow always" on first launch. Magisk users can
  set Superuser → Automatic response → Grant.
- The app opens one `su` process at launch and reuses it (`SuProcessRunner`),
  so the manager prompts at most once instead of per tap.

## Troubleshooting

- **"Root access denied" dialog:** grant superuser to the app in your root
  manager and retry. Check the manager isn't battery-killing the prompt.
- **"Please Make Sure You Flashed Latest Module Version!":** the
  `persist.ainjector.profile` prop is empty — reflash the module and reboot.
- **Switch reverts with toast:** the daemon didn't pick up the prop within
  ~9 s. Make sure the module is enabled and the device finished booting.
- **Build fails on configuration:** wrong JDK. AGP 8.13 + Gradle 9.2 must
  run on JDK 17 (see Building). Newer JDKs remove internal APIs AGP needs.
