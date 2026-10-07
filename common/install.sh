#!/system/bin/sh

bin_path="$MODPATH/system/bin"
device=$(getprop ro.product.device)
note="Boost your device's performance and enjoy a smoother experience with our optimizer, designed specifically for $device!"

# Read version from module.prop (single source of truth). Fall back if missing.
mod_prop="$MODPATH/module.prop"
version=$(sed -n 's/^version=//p' "$mod_prop" 2>/dev/null | head -n 1)
[ -z "$version" ] && version="unknown"

installation() {
  # awk '{print}' "$MODPATH/common/banner"
  ui_print ""
  ui_print "*******************************************"
  ui_print "*          Android Tweaker                *"
  ui_print "*  Unlocking Your Device's Potential      *"
  ui_print "*******************************************"
  ui_print ""
  ui_print "[*] version: $version"
  ui_print "[*] Developed by @c0d3h01 - Find me on GitHub"
  ui_print ""
  ui_print "[*] Gives a superpower to your device's performance"
  ui_print "[*] Bug reports: https://github.com/c0d3h01/AndroidTweaker/issues"
  ui_print ""

  if [ ! -f "$bin_path/Tweaks.sh" ]; then
    abort "! Tweaks.sh missing! Aborting!"
  fi
  ui_print "- Tweaks script ready ✓"
  ui_print ""

  # Safely update module.prop description with dynamic device name
  sed -i "s/^description=.*/description=$note/" "$MODPATH/module.prop"

  ui_print "- Installing AndroidTweaker App..."

  if [ "$BOOTMODE" = true ]; then
    if pm install -r -g "$MODPATH/AndroidTweaker.apk" >/dev/null 2>&1; then
      ui_print "  - App installed successfully ✓"
      rm -f "$MODPATH/AndroidTweaker.apk"
    else
      ui_print "  ! App will be installed on next boot."
    fi
  else
    ui_print "  - App will be installed on next boot."
  fi

  # Launch Telegram channel if installing from booted Android (not recovery)
  if [ "$BOOTMODE" = true ]; then
    ui_print "[*] Telegram Channel: @c0d3h01prjts (Official)"
    ui_print "[*] GitHub: https://github.com/c0d3h01/androidtweaker"
    ui_print "[*] Star this repository if you like the project :)"
    ui_print ""
  fi
}

installation
