#!/system/bin/sh
# Compat shim: the monolith moved to lib/. Resolves MODDIR explicitly,
# then hands off to the dispatcher with all args intact.
if [ -d "/data/adb/modules/android_tweaker" ]; then
  MODDIR="/data/adb/modules/android_tweaker"
else
  MODDIR=$(cd "${0%/*}/../.." 2>/dev/null && pwd -P)
fi
export MODDIR
exec sh "$MODDIR/lib/dispatcher.sh" "$@"
