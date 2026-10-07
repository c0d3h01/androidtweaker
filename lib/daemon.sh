#!/system/bin/sh
# lib/daemon.sh — profile watch loop. Launched via `dispatcher.sh daemon`
# (service.sh on boot). Runs misc once, then applies on prop change.
# Prop codes: 1=battery, 2=balanced, 3=performance, 4=gaming.

if [ -d "/data/adb/modules/android_tweaker" ]; then
  MODDIR="/data/adb/modules/android_tweaker"
else
  MODDIR=$(cd "${0%/*}/.." 2>/dev/null && pwd -P)
fi
export MODDIR

. "$MODDIR/lib/common.sh"

boot_run_once=false
at_mode=$(getprop persist.ainjector.profile)

[ -z "$at_mode" ] && setprop persist.ainjector.profile "2"

"$MODDIR/lib/dispatcher.sh" misc

while true; do
  sleep 3

  if $boot_run_once; then
    [ "$(getprop persist.ainjector.profile)" = "$at_mode" ] && continue
  else
    boot_run_once=true
  fi

  at_mode=$(getprop persist.ainjector.profile)

  case "$at_mode" in
  1)
    "$MODDIR/lib/dispatcher.sh" apply battery
    ;;
  2)
    "$MODDIR/lib/dispatcher.sh" apply balanced
    ;;
  3)
    "$MODDIR/lib/dispatcher.sh" apply performance
    ;;
  4)
    "$MODDIR/lib/dispatcher.sh" apply gaming
    ;;
  *)
    log "daemon: unknown profile '$at_mode' — falling back to balanced"
    "$MODDIR/lib/dispatcher.sh" apply balanced
    ;;
  esac
done
