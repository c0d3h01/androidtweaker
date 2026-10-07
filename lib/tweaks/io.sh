#!/system/bin/sh
# lib/tweaks/io.sh — block I/O scheduler tuning.
# Reads profile vars (IO_ADD_RANDOM, IO_IOSTATS, IO_READ_AHEAD,
# IO_NOMERGES, IO_RQ_AFFINITY, IO_NR_REQUESTS).

apply_io() {
  _S=${SYSFS_ROOT:-}
  for _q in "$_S"/sys/block/*/queue/; do
    write "${_q}add_random" "$IO_ADD_RANDOM"
    write "${_q}iostats" "$IO_IOSTATS"
    write "${_q}read_ahead_kb" "$IO_READ_AHEAD"
    write "${_q}nomerges" "$IO_NOMERGES"
    write "${_q}rq_affinity" "$IO_RQ_AFFINITY"
    write "${_q}nr_requests" "$IO_NR_REQUESTS"
  done
}
