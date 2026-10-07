#!/system/bin/sh
# lib/tweaks/fs.sh — filesystem notification/lease flags.
# Identical in every legacy profile; values hardcoded, no profile vars.

apply_fs() {
  _S=${SYSFS_ROOT:-}
  if [ -d "$_S/proc/sys/fs" ]; then
    write "$_S/proc/sys/fs/dir-notify-enable" "0"
    write "$_S/proc/sys/fs/lease-break-time" "20"
    write "$_S/proc/sys/fs/leases-enable" "1"
  fi
}
