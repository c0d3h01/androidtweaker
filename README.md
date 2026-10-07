# Android Tweaker

<a href="https://t.me/c0d3h01prjkts"><img src="https://img.shields.io/badge/Telegram-Channel-blue?logo=telegram&style=social"></a>

Android Tweaker tunes your device's CPU, GPU, memory and scheduler settings automatically to match how you use your phone. Pick a profile once in the companion app — the module applies it at boot and every time you switch.

## Requirements

- **Root manager:** Magisk v20.4+, KernelSU v0.6.6+, or APatch
- **Android:** 8.0 (API 26) or higher

## Installation

1. Download the latest `androidtweaker.zip` from the [Releases](https://github.com/c0d3h01/androidtweaker/releases) page
2. Open your root manager (Magisk / KernelSU / APatch)
3. Navigate to **Modules → Install from storage**
4. Select the downloaded zip and flash it
5. Reboot your device

The companion app installs automatically. The module activates about 30 seconds after boot and starts on the **Balanced** profile.

## How it works

The module watches the profile you select and applies a matching set of kernel tunings — processor speeds, graphics clocks, memory behavior, background task handling and touch response. Switching profiles in the app takes effect within seconds, no reboot needed. A light maintenance pass (storage trim and app optimization setup) runs once at every boot.

## Profiles

| Profile         | What it does                                                        | Use it when                         |
| --------------- | ------------------------------------------------------------------- | ----------------------------------- |
| **Battery**     | Lowers max speeds, enables battery saver, calms background activity | You need the longest screen-on time |
| **Balanced**    | Stock-like speeds with smoother scheduling (default)                | Everyday use                        |
| **Performance** | Locks speeds to maximum, sharpens responsiveness                    | Heavy multitasking, benchmarks      |
| **Gaming**      | Maximum speeds plus touch boost and aggressive graphics settings    | Gaming sessions                     |

Performance and Gaming keep clocks high, so expect more heat and faster battery drain while they are active. Switch back to Balanced or Battery afterwards.

## Uninstall

1. Remove the module in your root manager (**Modules → Remove**), or flash the module zip again
2. Reboot — the companion app is removed automatically and all settings revert

## Troubleshooting

- **Nothing seems applied:** make sure the module is enabled in your root manager and reboot once. Root (Magisk/KernelSU/APatch) must be working.
- **A profile feels wrong for your device:** switch to Balanced — it is the safe default on every device.
- **Still stuck:** report it with your device model, Android version and root solution on the [Issues](https://github.com/c0d3h01/AndroidTweaker/issues) page or the [Telegram channel](https://t.me/c0d3h01prjkts).
