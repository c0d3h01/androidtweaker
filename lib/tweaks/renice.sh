#!/system/bin/sh
# lib/tweaks/renice.sh — process priority tweaks. Shared verbatim by all profiles.

apply_renice() {
  renice -n -5 "$(pgrep system_server)" >/dev/null 2>&1
  renice -n -5 "$(pgrep com.miui.home)" >/dev/null 2>&1
  renice -n -5 "$(pgrep launcher)" >/dev/null 2>&1
  renice -n -5 "$(pgrep lawnchair)" >/dev/null 2>&1
  renice -n -5 "$(pgrep home)" >/dev/null 2>&1
  renice -n -5 "$(pgrep watchapp)" >/dev/null 2>&1
  renice -n -5 "$(pgrep trebuchet)" >/dev/null 2>&1
  renice -n -1 "$(pgrep dialer)" >/dev/null 2>&1
  renice -n -1 "$(pgrep keyboard)" >/dev/null 2>&1
  renice -n -1 "$(pgrep inputmethod)" >/dev/null 2>&1
  renice -n -9 "$(pgrep fluid)" >/dev/null 2>&1
  renice -n -10 "$(pgrep composer)" >/dev/null 2>&1
  renice -n -1 "$(pgrep com.android.phone)" >/dev/null 2>&1
  renice -n -10 "$(pgrep surfaceflinger)" >/dev/null 2>&1
  renice -n 1 "$(pgrep kswapd0)" >/dev/null 2>&1
  renice -n 1 "$(pgrep ksmd)" >/dev/null 2>&1
  renice -n -6 "$(pgrep msm_irqbalance)" >/dev/null 2>&1
  renice -n -9 "$(pgrep kgsl_worker)" >/dev/null 2>&1
  renice -n 6 "$(pgrep android.gms)" >/dev/null 2>&1
}
