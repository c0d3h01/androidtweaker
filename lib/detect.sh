#!/system/bin/sh
# lib/detect.sh — one-shot CPU/GPU detection.
# Every sysfs path is prefixed with ${SYSFS_ROOT:-} (empty on device)
# so tests can point detection at a fixture tree.
# Exports: CPU_GOVERNOR CPU_MAXFREQ CPU_HALF
#          GPU_DIR GPU_DEVFREQ GPU_MODEL GPU_GOVNAME
#          GPU_MINPL GPU_MAXFREQ GPU_HALF GPU_TOPMIN

detect_devices() {
  _S=${SYSFS_ROOT:-}

  GPU_DIR=""
  for _p in "$_S"/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0 \
    "$_S"/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0 \
    "$_S"/sys/devices/*.mali \
    "$_S"/sys/devices/platform/*.gpu \
    "$_S"/sys/devices/platform/mali-*.0; do
    if [ -d "$_p" ]; then
      GPU_DIR=$_p
    fi
  done
  if [ -d "$_S/sys/class/kgsl/kgsl-3d0" ]; then
    GPU_DIR="$_S/sys/class/kgsl/kgsl-3d0"
  elif [ -d "$_S/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
    GPU_DIR="$_S/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
  elif [ -d "$_S/sys/devices/platform/gpusysfs" ]; then
    GPU_DIR="$_S/sys/devices/platform/gpusysfs"
  elif [ -d "$_S/sys/devices/platform/mali.0" ]; then
    GPU_DIR="$_S/sys/devices/platform/mali.0"
  fi

  GPU_DEVFREQ=""
  for _p in "$_S"/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq \
    "$_S"/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq \
    "$_S"/sys/devices/platform/*.gpu; do
    if [ -d "$_p" ]; then
      GPU_DEVFREQ=$_p
    fi
  done
  if [ -d "$_S/sys/class/kgsl/kgsl-3d0/devfreq" ]; then
    GPU_DEVFREQ="$_S/sys/class/kgsl/kgsl-3d0/devfreq"
  elif [ -d "$_S/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq" ]; then
    GPU_DEVFREQ="$_S/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq"
  elif [ -d "$_S/sys/devices/platform/gpusysfs" ]; then
    GPU_DEVFREQ="$_S/sys/devices/platform/gpusysfs"
  elif [ -d "$_S/sys/module/mali/parameters" ]; then
    GPU_DEVFREQ="$_S/sys/module/mali/parameters"
  elif [ -d "$_S/sys/kernel/gpu" ]; then
    GPU_DEVFREQ="$_S/sys/kernel/gpu"
  fi

  _gpum=""
  for _p in "$_S"/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0 \
    "$_S"/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0; do
    if [ -d "$_p" ]; then
      _gpum=$_p
    fi
  done
  if [ -d "$_S/sys/class/kgsl/kgsl-3d0" ]; then
    _gpum="$_S/sys/class/kgsl/kgsl-3d0"
  elif [ -d "$_S/sys/kernel/gpu" ]; then
    _gpum="$_S/sys/kernel/gpu"
  fi

  GPU_MODEL=""
  if [ -e "$_gpum/gpu_model" ]; then
    GPU_MODEL=$(cat "$_gpum/gpu_model" | awk '{print $1}')
  fi
  GPU_GOVNAME=""
  if [ -e "$GPU_DEVFREQ/gpu_governor" ]; then
    GPU_GOVNAME=$(cat "$GPU_DEVFREQ/gpu_governor")
  elif [ -e "$GPU_DEVFREQ/governor" ]; then
    GPU_GOVNAME=$(cat "$GPU_DEVFREQ/governor")
  fi

  GPU_MINPL=""
  GPU_TOPMIN=""
  if [ -e "$GPU_DIR/min_pwrlevel" ]; then
    GPU_MINPL=$(cat "$GPU_DIR/min_pwrlevel")
    GPU_TOPMIN=$((GPU_MINPL + 1))
  fi

  GPU_TOPMIN_FREQ=""
  if [ -e "$GPU_DIR/devfreq/available_frequencies" ]; then
    GPU_TOPMIN_FREQ=$(cat "$GPU_DIR/devfreq/available_frequencies" | awk -v var="$GPU_TOPMIN" '{print $var}')
    if [ "$GPU_TOPMIN_FREQ" != "$(cat "$GPU_DIR/max_gpuclk")" ]; then
      GPU_TOPMIN_FREQ=$(cat "$GPU_DIR/devfreq/available_frequencies" | awk '{print $1}')
    fi
  fi

  CPU_GOVERNOR=""
  for _cpu in "$_S"/sys/devices/system/cpu/cpu*/cpufreq/; do
    if [ -e "${_cpu}scaling_governor" ]; then
      CPU_GOVERNOR=$(cat "${_cpu}scaling_governor")
    fi
  done
  CPU_MAXFREQ=""
  for _cpu in "$_S"/sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -e "$_cpu/scaling_max_freq" ]; then
      _mx=$(cat "$_cpu/scaling_max_freq")
      _mx2=""
      if [ -e "$_cpu/cpuinfo_max_freq" ]; then
        _mx2=$(cat "$_cpu/cpuinfo_max_freq")
      fi
      if [ -n "$_mx2" ] && [ "$_mx2" -gt "$_mx" ]; then
        _mx=$_mx2
      fi
      CPU_MAXFREQ=$_mx
    fi
  done

  CPU_HALF=$((CPU_MAXFREQ / 2))
  GPU_MAXFREQ=$(cat "$GPU_DIR/max_gpuclk")
  GPU_HALF=$((GPU_MAXFREQ / 2))
}
