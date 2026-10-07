#!/system/bin/sh
# lib/common.sh — shared helpers for the split tweaks tree.
# Sourced by dispatcher, daemon, profiles and lib/tweaks modules.
# Callers set MODDIR; resolve_moddir() fills it when empty.

# DRY_RUN=1: write() echoes the change instead of touching sysfs.

resolve_moddir() {
  if [ -n "$MODDIR" ] && [ -d "$MODDIR" ]; then
    return 0
  fi
  if [ -d "/data/adb/modules/android_tweaker" ]; then
    MODDIR="/data/adb/modules/android_tweaker"
    return 0
  fi
  _rmd="${0%/*}"
  if [ "$_rmd" = "$0" ]; then
    _rmd="."
  fi
  _rmi=0
  while [ "$_rmi" -lt 4 ]; do
    if [ -f "$_rmd/module.prop" ]; then
      MODDIR=$(cd "$_rmd" 2>/dev/null && pwd -P)
      return 0
    fi
    _rmd="$_rmd/.."
    _rmi=$((_rmi + 1))
  done
  return 1
}

log() {
  _logfile="${MODDIR:-/tmp}/tweaks.log"
  echo "$*" >> "$_logfile" 2>/dev/null
  echo "$*"
}

has() {
  [ -e "$1" ]
}

write() {
  if [ ! -f "$1" ]; then
    log "skip: $1 missing" >/dev/null
    return 1
  fi
  _curval=$(cat "$1" 2>/dev/null)
  if [ "$_curval" = "$2" ]; then
    log "skip: $1 already $2" >/dev/null
    return 1
  fi
  if [ "${DRY_RUN:-0}" = "1" ]; then
    log "dry-run: $1 $_curval -> $2"
    return 0
  fi
  chmod +w "$1" 2>/dev/null
  if ! echo "$2" >"$1" 2>/dev/null; then
    log "fail: $1 -> $2"
    return 1
  fi
  log "write: $1 $_curval -> $2"
  return 0
}
