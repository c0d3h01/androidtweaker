#!/system/bin/sh
MODDIR=${0%/*}

# Wait until the device has finished booting. Poll up to ~5 min,
# then give the system a short settle window before installing.
i=0
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  i=$((i + 1))
  [ $i -ge 60 ] && break
  sleep 5
done

# Settle window for package manager, storage, and system services.
sleep 15

# Fast path: nothing to install and legacy already handled.
if [ ! -f "$MODDIR/AndroidTweaker.apk" ] && [ -f "$MODDIR/.legacy_removed" ]; then
  sh "$MODDIR/system/bin/Tweaks.sh" daemon >/dev/null 2>&1
  exit 0
fi

# Read the companion app's package name from module.prop.
pkg=$(sed -n 's/^companionPkg=//p' "$MODDIR/module.prop" 2>/dev/null | head -n 1)

if [ -f "$MODDIR/AndroidTweaker.apk" ]; then
  pm install -r -g "$MODDIR/AndroidTweaker.apk" >/dev/null 2>&1
  rm -f "$MODDIR/AndroidTweaker.apk"
fi

# One-time upgrade: drop the legacy companion (renamed package).
# Sentinel-gated so the package-manager scan runs once, not every boot.
if [ ! -f "$MODDIR/.legacy_removed" ]; then
  if pm list packages 2>/dev/null | grep -q '^package:beastmode\.profile$'; then
    pm uninstall beastmode.profile >/dev/null 2>&1
  fi
  touch "$MODDIR/.legacy_removed"
fi

sh "$MODDIR/system/bin/Tweaks.sh" daemon >/dev/null 2>&1
exit 0
