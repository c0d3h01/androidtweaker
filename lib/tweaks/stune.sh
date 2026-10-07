#!/system/bin/sh
# lib/tweaks/stune.sh — schedtune cgroup tuning.
# Reads profile vars (STUNE_BG_BOOST, STUNE_BG_IDLE, STUNE_FG_BOOST,
# STUNE_FG_IDLE, STUNE_RT_BOOST, STUNE_RT_IDLE, STUNE_TOP_BOOST,
# STUNE_TOP_IDLE, STUNE_BOOST, STUNE_IDLE).

apply_stune() {
  _S=${SYSFS_ROOT:-}
  if [ -d "$_S/dev/stune/" ]; then
    write "$_S/dev/stune/background/schedtune.boost" "$STUNE_BG_BOOST"
    write "$_S/dev/stune/background/schedtune.prefer_idle" "$STUNE_BG_IDLE"
    write "$_S/dev/stune/foreground/schedtune.boost" "$STUNE_FG_BOOST"
    write "$_S/dev/stune/foreground/schedtune.prefer_idle" "$STUNE_FG_IDLE"
    write "$_S/dev/stune/rt/schedtune.boost" "$STUNE_RT_BOOST"
    write "$_S/dev/stune/rt/schedtune.prefer_idle" "$STUNE_RT_IDLE"
    write "$_S/dev/stune/top-app/schedtune.boost" "$STUNE_TOP_BOOST"
    write "$_S/dev/stune/top-app/schedtune.prefer_idle" "$STUNE_TOP_IDLE"
    write "$_S/dev/stune/schedtune.boost" "$STUNE_BOOST"
    write "$_S/dev/stune/schedtune.prefer_idle" "$STUNE_IDLE"
  fi
}
