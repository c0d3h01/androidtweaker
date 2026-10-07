#!/system/bin/sh
# lib/tweaks/display.sh — double-tap-to-wake, LCD, idle sleep, touch boost.
# DT2W writes are identical everywhere (hardcoded); the rest reads profile
# vars (LCD_POWER, PM2_IDLE optional, TOUCHBOOST, BATTERY_SAVER and
# ARCH_POWER optional).

apply_display() {
  _S=${SYSFS_ROOT:-}
  if [ -e "$_S/sys/touchpanel/double_tap" ] && [ -e "$_S/proc/tp_gesture" ]; then
    write "$_S/sys/touchpanel/double_tap" "1"
    write "$_S/proc/tp_gesture" "1"
  elif [ -e "$_S/proc/tp_gesture" ]; then
    write "$_S/proc/tp_gesture" "1"
  elif [ -e "$_S/sys/touchpanel/double_tap" ]; then
    write "$_S/sys/touchpanel/double_tap" "1"
  fi

  if [ -e "$_S/sys/module/msm_performance/parameters/touchboost" ]; then
    write "$_S/sys/module/msm_performance/parameters/touchboost" "$TOUCHBOOST"
  elif [ -e "$_S/sys/power/pnpmgr/touch_boost" ]; then
    write "$_S/sys/power/pnpmgr/touch_boost" "$TOUCHBOOST"
  fi

  if [ -n "${BATTERY_SAVER:-}" ] && [ -d "$_S/sys/module/battery_saver" ]; then
    write "$_S/sys/module/battery_saver/parameters/enabled" "$BATTERY_SAVER"
  fi

  if [ -n "${ARCH_POWER:-}" ] && [ -e "$_S/sys/kernel/sched/arch_power" ]; then
    write "$_S/sys/kernel/sched/arch_power" "$ARCH_POWER"
  fi

  if [ -n "${PM2_IDLE:-}" ] && [ -e "$_S/sys/module/pm2/parameters/idle_sleep_mode" ]; then
    write "$_S/sys/module/pm2/parameters/idle_sleep_mode" "$PM2_IDLE"
  fi

  if [ -e "$_S/sys/class/lcd/panel/power_reduce" ]; then
    write "$_S/sys/class/lcd/panel/power_reduce" "$LCD_POWER"
  fi
}
