#!/system/bin/sh
# lib/tweaks/cpu.sh — governor, boost, clock and idle tuning.
# Reads profile vars (CPU_SU_*, CPU_INT_*, CPU_MIN_FREQ, CPU_MAX_FREQ,
# CPU_BOOST_MS, CPU_IBOOST_DUR, CPU_IBOOST_FREQ, CPU_CORE_CTL, CPU_DEEPEST).
# Governor *availability* is probed here (capability read, not tuning state).

apply_cpu() {
  _S=${SYSFS_ROOT:-}
  for _cpu in "$_S"/sys/devices/system/cpu/cpu*/cpufreq/; do
    if [ ! -e "${_cpu}scaling_available_governors" ]; then
      continue
    fi
    _avail=$(cat "${_cpu}scaling_available_governors")
    case "$_avail" in
    *schedutil*)
      write "${_cpu}scaling_governor" schedutil
      write "${_cpu}schedutil/up_rate_limit_us" "$CPU_SU_UP"
      write "${_cpu}schedutil/down_rate_limit_us" "$CPU_SU_DOWN"
      write "${_cpu}schedutil/pl" "$CPU_SU_PL"
      write "${_cpu}schedutil/iowait_boost_enable" "$CPU_SU_IOWAIT"
      write "${_cpu}schedutil/rate_limit_us" "$CPU_SU_RATE"
      write "${_cpu}schedutil/hispeed_load" "$CPU_SU_HISPEED_LOAD"
      write "${_cpu}schedutil/hispeed_freq" "$CPU_SU_HISPEED_FREQ"
      ;;
    *interactive*)
      write "${_cpu}scaling_governor" interactive
      write "${_cpu}interactive/timer_rate" "$CPU_INT_TIMER_RATE"
      write "${_cpu}interactive/boost" "$CPU_INT_BOOST"
      write "${_cpu}interactive/timer_slack" "$CPU_INT_TIMER_SLACK"
      write "${_cpu}interactive/use_migration_notif" "$CPU_INT_MIGRATION"
      write "${_cpu}interactive/ignore_hispeed_on_notif" "$CPU_INT_IGNORE_HISPEED"
      write "${_cpu}interactive/use_sched_load" "$CPU_INT_SCHED_LOAD"
      write "${_cpu}interactive/boostpulse" "$CPU_INT_BOOSTPULSE"
      write "${_cpu}interactive/fastlane" "$CPU_INT_FASTLANE"
      write "${_cpu}interactive/fast_ramp_down" "$CPU_INT_FAST_RAMP_DOWN"
      write "${_cpu}interactive/sampling_rate" "$CPU_INT_SAMPLING"
      write "${_cpu}interactive/sampling_rate_min" "$CPU_INT_SAMPLING_MIN"
      write "${_cpu}interactive/min_sample_time" "$CPU_INT_MIN_SAMPLE"
      write "${_cpu}interactive/go_hispeed_load" "$CPU_INT_GO_HISPEED"
      write "${_cpu}interactive/hispeed_freq" "$CPU_INT_HISPEED_FREQ"
      ;;
    esac
  done

  if [ -n "${CPU_BOOST_MS:-}" ] && [ -d "$_S/sys/module/cpu_boost" ]; then
    write "$_S/sys/module/cpu_boost/parameters/input_boost_freq" "$CPU_IBOOST_FREQ"
    write "$_S/sys/module/cpu_boost/parameters/input_boost_ms" "$CPU_BOOST_MS"
  elif [ -n "${CPU_IBOOST_DUR:-}" ] && [ -d "$_S/sys/module/cpu_input_boost" ]; then
    write "$_S/sys/module/cpu_input_boost/parameters/input_boost_duration" "$CPU_IBOOST_DUR"
    write "$_S/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$CPU_IBOOST_FREQ"
    write "$_S/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$CPU_IBOOST_FREQ"
  fi

  for _clk in "$_S"/sys/devices/system/cpu/cpufreq/policy*/ "$_S"/sys/devices/system/cpu/cpu*/cpufreq/; do
    if [ -e "${_clk}scaling_min_freq" ]; then
      write "${_clk}scaling_min_freq" "$CPU_MIN_FREQ"
      write "${_clk}scaling_max_freq" "$CPU_MAX_FREQ"
    fi
  done

  if [ -n "${CPU_CORE_CTL:-}" ]; then
    for _ctl in "$_S"/sys/devices/system/cpu/cpu*/core_ctl; do
      if [ -e "$_ctl/enable" ]; then
        write "$_ctl/enable" "1"
      elif [ -e "$_ctl/disable" ]; then
        write "$_ctl/disable" "0"
      fi
    done
  fi

  if [ -e "$_S/sys/devices/system/cpu/cpuidle/use_deepest_state" ]; then
    write "$_S/sys/devices/system/cpu/cpuidle/use_deepest_state" "$CPU_DEEPEST"
  fi
}
