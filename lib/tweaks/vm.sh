#!/system/bin/sh
# lib/tweaks/vm.sh — virtual-memory tuning plus cache sync/drop.
# Reads profile vars (VM_DIRTY_BG, VM_DIRTY_RATIO, VM_DIRTY_EXPIRE,
# VM_DIRTY_WRITEBACK, VM_PAGE_CLUSTER, VM_STAT_INTERVAL, VM_SWAPPINESS,
# VM_LAPTOP_MODE, VM_VFS_PRESSURE; optional VM_DROP_WRITE).

apply_vm() {
  _S=${SYSFS_ROOT:-}
  sync
  sysctl -w vm.drop_caches=3 >/dev/null 2>&1
  if [ -n "${VM_DROP_WRITE:-}" ]; then
    write "$_S/proc/sys/vm/drop_caches" "$VM_DROP_WRITE"
  fi
  write "$_S/proc/sys/vm/dirty_background_ratio" "$VM_DIRTY_BG"
  write "$_S/proc/sys/vm/dirty_ratio" "$VM_DIRTY_RATIO"
  write "$_S/proc/sys/vm/dirty_expire_centisecs" "$VM_DIRTY_EXPIRE"
  write "$_S/proc/sys/vm/dirty_writeback_centisecs" "$VM_DIRTY_WRITEBACK"
  write "$_S/proc/sys/vm/page-cluster" "$VM_PAGE_CLUSTER"
  write "$_S/proc/sys/vm/stat_interval" "$VM_STAT_INTERVAL"
  write "$_S/proc/sys/vm/swappiness" "$VM_SWAPPINESS"
  write "$_S/proc/sys/vm/laptop_mode" "$VM_LAPTOP_MODE"
  write "$_S/proc/sys/vm/vfs_cache_pressure" "$VM_VFS_PRESSURE"
}
