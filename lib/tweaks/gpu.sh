#!/system/bin/sh
# lib/tweaks/gpu.sh — GPU clocks, power and idler tuning.
# Reads profile vars (GPU_THROTTLE, GPU_PWRLEVEL, GPU_ADRENOBOOST,
# GPU_NONAP, GPU_BUS_SPLIT, GPU_MAX_FREQ_SET, GPU_MIN_FREQ_SET,
# GPU_DEF_PWRLEVEL, GPU_FORCE_BUS, GPU_FORCE_CLK, GPU_FORCE_RAIL,
# GPU_IDLE_TIMER, GPU_THERMAL_IGNORE, GPU_IDLER, GPU_IDLER_WORKLOAD,
# GPU_IDLER_DOWNDIFF, GPU_IDLER_IDLEWAIT) plus detect exports
# (GPU_DIR, GPU_DEVFREQ).

apply_gpu() {
  _S=${SYSFS_ROOT:-}
  write "$GPU_DIR/throttling" "$GPU_THROTTLE"
  write "$GPU_DIR/thermal_pwrlevel" "$GPU_PWRLEVEL"
  write "$GPU_DIR/devfreq/adrenoboost" "$GPU_ADRENOBOOST"
  write "$GPU_DIR/force_no_nap" "$GPU_NONAP"
  write "$GPU_DIR/bus_split" "$GPU_BUS_SPLIT"
  write "$GPU_DIR/devfreq/max_freq" "$GPU_MAX_FREQ_SET"
  write "$GPU_DIR/devfreq/min_freq" "$GPU_MIN_FREQ_SET"
  write "$GPU_DIR/default_pwrlevel" "$GPU_DEF_PWRLEVEL"
  write "$GPU_DIR/force_bus_on" "$GPU_FORCE_BUS"
  write "$GPU_DIR/force_clk_on" "$GPU_FORCE_CLK"
  write "$GPU_DIR/force_rail_on" "$GPU_FORCE_RAIL"
  write "$GPU_DIR/idle_timer" "$GPU_IDLE_TIMER"

  if [ -e "$_S/proc/gpufreq/gpufreq_limited_thermal_ignore" ]; then
    write "$_S/proc/gpufreq/gpufreq_limited_thermal_ignore" "$GPU_THERMAL_IGNORE"
  fi
  if [ -e "$_S/proc/mali/dvfs_enable" ]; then
    write "$_S/proc/mali/dvfs_enable" "1"
  fi
  if [ -e "$_S/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]; then
    write "$_S/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
  fi
  if [ -e "$_S/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]; then
    write "$_S/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
  fi

  if [ -d "$_S/sys/module/adreno_idler" ]; then
    write "$_S/sys/module/adreno_idler/parameters/adreno_idler_active" "$GPU_IDLER"
    if [ "$GPU_IDLER" = "Y" ]; then
      write "$_S/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "$GPU_IDLER_WORKLOAD"
      write "$_S/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "$GPU_IDLER_DOWNDIFF"
      write "$_S/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "$GPU_IDLER_IDLEWAIT"
    fi
  fi
}
