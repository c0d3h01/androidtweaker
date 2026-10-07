#!/system/bin/sh
# lib/dispatcher.sh — CLI parse + route only. No watch loop (see daemon.sh).
# Usage: dispatcher.sh apply <battery|balanced|performance|gaming> | daemon | misc

if [ -d "/data/adb/modules/android_tweaker" ]; then
  MODDIR="/data/adb/modules/android_tweaker"
else
  MODDIR=$(cd "${0%/*}/.." 2>/dev/null && pwd -P)
fi
export MODDIR

. "$MODDIR/lib/common.sh"
. "$MODDIR/lib/notify.sh"
. "$MODDIR/lib/detect.sh"
. "$MODDIR/lib/tweaks/renice.sh"
. "$MODDIR/lib/tweaks/cpu.sh"
. "$MODDIR/lib/tweaks/gpu.sh"
. "$MODDIR/lib/tweaks/io.sh"
. "$MODDIR/lib/tweaks/sched.sh"
. "$MODDIR/lib/tweaks/stune.sh"
. "$MODDIR/lib/tweaks/thermal.sh"
. "$MODDIR/lib/tweaks/vm.sh"
. "$MODDIR/lib/tweaks/fs.sh"
. "$MODDIR/lib/tweaks/display.sh"
. "$MODDIR/lib/tweaks/ksm.sh"
. "$MODDIR/lib/tweaks/misc.sh"

usage() {
  echo "usage: $0 apply <battery|balanced|performance|gaming> | daemon | misc" >&2
  exit 1
}

do_apply() {
  case "$1" in
  battery | balanced | performance | gaming) ;;
  *)
    usage
    ;;
  esac
  notify "applying : $1"
  detect_devices
  . "$MODDIR/profiles/$1.sh"
  case "$1" in
  battery)
    settings put global device_idle_constants inactive_to=60000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=21600000,idle_factor=2.0,max_temp_app_whitelist_duration=60000,mms_temp_app_whitelist_duration=30000,sms_temp_app_whitelist_duration=20000,light_after_inactive_to=10000,light_pre_idle_to=60000,light_idle_to=180000,light_idle_factor=2.0,light_max_idle_to=900000,light_idle_maintenance_min_budget=30000,light_idle_maintenance_max_budget=60000
    settings put global low_power 1
    ;;
  balanced)
    settings put global low_power 0
    ;;
  performance | gaming)
    settings delete global device_idle_constants
    settings put global low_power 0
    ;;
  esac
  stop logd >/dev/null 2>&1
  stop statsd >/dev/null 2>&1
  start perfd >/dev/null 2>&1
  "$MPDECISION" mpdecision >/dev/null 2>&1
  notify "Applied : $1"
}

case "${1:-}" in
apply)
  [ -n "${2:-}" ] || usage
  do_apply "$2"
  ;;
daemon)
  exec "$MODDIR/lib/daemon.sh"
  ;;
misc)
  apply_misc
  notify "Misc Tweaks successfully executed"
  ;;
*)
  usage
  ;;
esac
