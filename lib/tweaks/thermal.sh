#!/system/bin/sh
# lib/tweaks/thermal.sh — thermal and power-efficiency toggles.
# Reads profile vars (MSM_VDD, MSM_CORE, MSM_ENABLED, WQ_EFFICIENT, SCHED_MC).

apply_thermal() {
  _S=${SYSFS_ROOT:-}
  if [ -d "$_S/sys/module/msm_thermal" ]; then
    write "$_S/sys/module/msm_thermal/vdd_restriction/enabled" "$MSM_VDD"
    write "$_S/sys/module/msm_thermal/core_control/enabled" "$MSM_CORE"
    write "$_S/sys/module/msm_thermal/parameters/enabled" "$MSM_ENABLED"
  fi
  if [ -e "$_S/sys/module/workqueue/parameters/power_efficient" ]; then
    write "$_S/sys/module/workqueue/parameters/power_efficient" "$WQ_EFFICIENT"
  fi
  if [ -e "$_S/sys/devices/system/cpu/sched_mc_power_savings" ]; then
    write "$_S/sys/devices/system/cpu/sched_mc_power_savings" "$SCHED_MC"
  fi
}
