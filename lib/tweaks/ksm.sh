#!/system/bin/sh
# lib/tweaks/ksm.sh — kernel same-page merging toggles.
# Reads profile var KSM_RUN (0 disables, 1 enables; uksm mirrors ksm).

apply_ksm() {
  _S=${SYSFS_ROOT:-}
  if [ -e "$_S/sys/kernel/mm/ksm/run" ]; then
    write "$_S/sys/kernel/mm/ksm/run" "$KSM_RUN"
  elif [ -e "$_S/sys/kernel/mm/uksm/run" ]; then
    write "$_S/sys/kernel/mm/uksm/run" "$KSM_RUN"
  fi
}
