# Contributing to AndroidTweaker

## What you need

| Tool                             | Version                                   | Notes                                                                                                                                      |
| -------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| JDK                              | 17                                        | Required. Newer JDKs break the build (AGP 8.13 + Gradle 9.2 use internal Gradle APIs removed in 9.6+). Install per OS, then point `JAVA_HOME` at it — see below |
| Gradle                           | 9.2                                       | Any install works (Homebrew, SDKMAN, wrapper dists). Do **not** use Gradle ≥ 9.6                                                           |
| Android SDK                      | compileSdk 34, build-tools 37             | Set `ANDROID_HOME` / `ANDROID_SDK_ROOT` to your SDK                                                                                        |
| `zip`                            | any                                       | For packing the flashable module                                                                                                           |
| A rooted test device or emulator | Magisk v20.4+ / KernelSU v0.6.6+ / APatch | With USB debugging for `adb`                                                                                                               |

Set `JAVA_HOME` to your JDK 17 **before** launching VSCode — the editor's
Gradle server inherits it (repo `.vscode/settings.json` resolves
`${env:JAVA_HOME}`, no hardcoded paths):

| OS | Install JDK 17 | Example `JAVA_HOME` |
| -- | -------------- | ------------------- |
| macOS | `brew install openjdk@17` | `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` |
| Linux (Debian/Ubuntu) | `sudo apt install openjdk-17-jdk` | `/usr/lib/jvm/java-17-openjdk-amd64` |
| Linux (others) | SDKMAN: `sdk install java 17-tem` | `~/.sdkman/candidates/java/17-tem` |
| Windows | winget: `winget install EclipseAdoptium.Temurin.17.JDK` | `C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot` |

Verify (any OS, fresh terminal):

```bash
java -version                        # must say 17
gradle --version                     # must say 9.2
echo $ANDROID_HOME                   # must point at your SDK
```

## First build (5 minutes)

```bash
git clone <repo-url> && cd androidtweaker

# 1. Unit tests — 20 tests, no device needed (./gradlew is pinned to 9.2.0)
./gradlew :app:testDebugUnitTest

# 2. Signed release APK staged at app/release/androidtweaker.apk
./gradlew :app:stageReleaseApk

# 3. Verify the signature (any build-tools version in your SDK works)
apksigner verify app/release/androidtweaker.apk
```

No setup beyond that: the dev signing key (`app/release.keystore`) and its
config (`app/release.properties`) are committed, so every clone builds an
installable, identically-signed APK. Machine-local overrides go in the
ignored root `local.properties`.

## Packing the flashable module

The module zip is the repo root **plus** the built APK at the zip root as
`AndroidTweaker.apk` (installed on boot by `service.sh` via
`pm install -r -g`). Dev-only paths (`app/`, `gradle/`, `docs/`,
`application/`, `branding/`, `.github/`, root Gradle scripts) are stripped
on-device by `cleanup()` in `common/functions.sh`, but exclude them from the
zip anyway:

```bash
gradle :app:stageReleaseApk
cp app/release/androidtweaker.apk AndroidTweaker.apk   # zip-root name the installer expects
zip -r AndroidTweaker.zip . -x 'app/*' 'gradle/*' 'docs/*' 'application/*' 'branding/*' \
  '.git/*' '.gradle/*' '.superpowers/*' '.github/*' '*.apk' \
  'settings.gradle.kts' 'build.gradle.kts' 'gradle.properties' 'local.properties'
# then add back ONLY the zip-root APK:
zip AndroidTweaker.zip AndroidTweaker.apk && rm AndroidTweaker.apk
```

Flash `AndroidTweaker.zip` in Magisk / KernelSU / APatch Manager, reboot,
grant root to the app when prompted (Allow always), pick a profile.

## Release process (production versioning)

One version everywhere: the module and the app share `vX.Y.Z` /
`versionCode = X*100 + Y*10 + Z` (e.g. v1.6.0 → 160). Never bump one
without the other — bug reports must map to a single version.

```bash
# 1. edit module.prop (version, versionCode), update.json, app versionName/Code
# 2. add CHANGELOG.md entry
# 3. make release        # rebuilds + restages signed APK (version is baked in)
# 4. make check          # tests + shell syntax
# 5. make pack           # flashable zip (test flash on rooted device first)
# 6. tag vX.Y.Z, GitHub release with the zip (update.json points there for OTA)
```

Rules: SemVer (`CHANGELOG.md` keeps the history); `versionCode` only ever
increases; the release keystore never rotates (updates + root grants bind
to package + certificate).

## Project layout

```
.
├── app/                  # companion app (Kotlin + Compose, see app/README.md)
│   ├── release/androidtweaker.apk  # staged signed release (committed)
│   ├── release.keystore  # shared dev signing key (committed — keep repo private)
│   └── src/main/...      # App, MainActivity, data/, util/, ui/, res/
├── lib/                  # module runtime: dispatcher.sh, daemon.sh, common.sh, misc/
├── profiles/             # battery.sh, balanced.sh, performance.sh, gaming.sh
├── system/bin/Tweaks.sh  # on-device entry: reads prop, calls dispatcher apply
├── common/functions.sh   # MMT-Extended installer + cleanup() allowlist
├── customize.sh          # install-time perms + Tweaks.sh verification
├── service.sh            # boot: installs APK, one-time legacy-package removal
├── uninstall.sh          # removes companion app, restores backups
├── branding/             # logo.svg, banner-readme.svg, app-icon.svg
├── application/          # decompiled legacy APK reference (not shipped)
└── module.prop           # id, version, companionPkg=com.c0d3h01.androidtweaker
```

How a tap becomes silicon: app writes `persist.ainjector.profile`
(`1` battery, `2` balanced, `3` performance, `4` gaming) → `daemon.sh`
polls every 3 s → `dispatcher.sh apply <name>` → sysfs + settings.
The app never touches sysfs directly (setprop-only rule).

## Testing

```bash
./gradlew :app:testDebugUnitTest          # full JVM suite, must be 20/20 green
./gradlew :app:testDebugUnitTest --tests "*.ProfileTest"   # one file
sh -n service.sh customize.sh uninstall.sh common/functions.sh  # shell syntax
```

On device: switch each of the 4 profiles, confirm via
`getprop persist.ainjector.profile` + spot-check a sysfs node, reboot and
confirm persistence, deny-root path shows the dialog, uninstall removes the
app. Write the failing test first for any logic change (TDD); shell changes
get a syntax check at minimum.

## Signing rules (read before touching)

- Never rotate `app/release.keystore`. Package name + certificate =
  update identity + root-grant continuity. Rotation forces uninstall/reinstall
  for every user.
- Never add Play/App-store upload keys here. This dev key is for sideload
  and module-bundled installs only.
- Keep this repo access-controlled: anyone with read access can publish
  updates as `com.c0d3h01.androidtweaker`.

## Style

- Kotlin: official style, minimal diffs, no new dependencies without
  justification (stdlib first).
- Shell: `#!/system/bin/sh`, quote paths, `>/dev/null 2>&1` for noisy
  boot-time commands, keep `set -euo pipefail` semantics in mind
  (Magisk `sh` is mksh — test on device, not just `sh -n`).
- Docs live next to code (`app/README.md` for the app, this file for the
  repo). Update them in the same change, not after.
