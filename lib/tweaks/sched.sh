#!/system/bin/sh
# lib/tweaks/sched.sh — kernel scheduler tuning.
# Reads profile vars (SCHED_CHILD_FIRST, SCHED_BOOST, SCHED_PERF_PCT,
# SCHED_AUTOGROUP, SCHED_RAND_READ, SCHED_RAND_WRITE, SCHED_RESEED,
# SCHED_TUNABLE_SCALING, SCHED_LATENCY, SCHED_MIN_GRAN, SCHED_WAKEUP_GRAN,
# SCHED_MIGRATION_COST, SCHED_COLOCATION, SCHED_NR_MIGRATE, SCHED_STATS,
# SCHED_SYNC_HINT, SCHED_USER_HINT, SCHED_GENTLE, SCHED_FEATURES list; optional
# SCHED_CONSERVATIVE_PL for performance-class profiles).

apply_sched() {
  _S=${SYSFS_ROOT:-}
  if [ -e "$_S/sys/kernel/debug/sched_features" ]; then
    for _f in $SCHED_FEATURES; do
      write "$_S/sys/kernel/debug/sched_features" "$_f"
    done
  fi
  write "$_S/proc/sys/kernel/sched_child_runs_first" "$SCHED_CHILD_FIRST"
  write "$_S/proc/sys/kernel/sched_boost" "$SCHED_BOOST"
  write "$_S/proc/sys/kernel/perf_cpu_time_max_percent" "$SCHED_PERF_PCT"
  write "$_S/proc/sys/kernel/sched_autogroup_enabled" "$SCHED_AUTOGROUP"
  write "$_S/proc/sys/kernel/random/read_wakeup_threshold" "$SCHED_RAND_READ"
  write "$_S/proc/sys/kernel/random/write_wakeup_threshold" "$SCHED_RAND_WRITE"
  write "$_S/proc/sys/kernel/random/urandom_min_reseed_secs" "$SCHED_RESEED"
  write "$_S/proc/sys/kernel/sched_tunable_scaling" "$SCHED_TUNABLE_SCALING"
  write "$_S/proc/sys/kernel/sched_latency_ns" "$SCHED_LATENCY"
  write "$_S/proc/sys/kernel/sched_min_granularity_ns" "$SCHED_MIN_GRAN"
  write "$_S/proc/sys/kernel/sched_wakeup_granularity_ns" "$SCHED_WAKEUP_GRAN"
  write "$_S/proc/sys/kernel/sched_migration_cost_ns" "$SCHED_MIGRATION_COST"
  write "$_S/proc/sys/kernel/sched_min_task_util_for_colocation" "$SCHED_COLOCATION"
  write "$_S/proc/sys/kernel/sched_nr_migrate" "$SCHED_NR_MIGRATE"
  write "$_S/proc/sys/kernel/sched_schedstats" "$SCHED_STATS"
  write "$_S/proc/sys/kernel/sched_sync_hint_enable" "$SCHED_SYNC_HINT"
  write "$_S/proc/sys/kernel/sched_user_hint" "$SCHED_USER_HINT"
  if [ -n "${SCHED_CONSERVATIVE_PL:-}" ]; then
    write "$_S/proc/sys/kernel/sched_conservative_pl" "$SCHED_CONSERVATIVE_PL"
  fi
  if [ -e "$_S/sys/kernel/sched/gentle_fair_sleepers" ]; then
    write "$_S/sys/kernel/sched/gentle_fair_sleepers" "$SCHED_GENTLE"
  fi
  write "$_S/proc/sys/kernel/printk_devkmsg" "off"
}
