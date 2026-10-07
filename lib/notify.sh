#!/system/bin/sh
# lib/notify.sh — single notification entrypoint.
# Replaces NOTIFYER1 / NOTIFYER2 / miscnotify().

notify() {
  su -lp 2000 -c "cmd notification post -S bigtext -t 'AndroidXTweaker' 'Tag' '$1'" >/dev/null 2>&1
}
