#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")
BUILD_DIR="${SCRIPT_DIR}/../../build/astra_analytical/build/bin"
WORKLOAD="${SCRIPT_DIR}/inputs/workload/tp_tail"
SYSTEM="${SCRIPT_DIR}/inputs/system_cfg.json"
NETWORK="${SCRIPT_DIR}/inputs/network_cfg.yml"
MEMORY="${SCRIPT_DIR}/inputs/remote_memory_cfg.json"

rm -rf "${SCRIPT_DIR}/outputs"/*
"${SCRIPT_DIR}/inputs/workload/gen.sh"

run_backend() {
    local name=$1
    local binary=$2
    local output_dir="${SCRIPT_DIR}/outputs/${name}"
    mkdir -p "${output_dir}/log"

    (
        cd "${output_dir}"
        printf "pass\nexit\n" | "${binary}" \
            --workload-configuration="${WORKLOAD}" \
            --system-configuration="${SYSTEM}" \
            --network-configuration="${NETWORK}" \
            --memory-configuration="${MEMORY}" \
            --start-npu-ids=0 \
            --end-npu-ids=3
    ) | tee "${output_dir}/stdout.txt"

    local start_tick
    local end_tick
    start_tick=$(sed -n 's/.*sys\[0\] iteration 0 finished, \([0-9][0-9]*\) cycles.*/\1/p' \
        "${output_dir}/log/log.log" | tail -n 1)
    end_tick=$(sed -n 's/.*sys\[3\] iteration 0 finished, \([0-9][0-9]*\) cycles.*/\1/p' \
        "${output_dir}/log/log.log" | tail -n 1)

    test -n "${start_tick}"
    test -n "${end_tick}"
    test "${end_tick}" -gt "${start_tick}"
    grep -q "All Request Has Been Exited" "${output_dir}/stdout.txt"
    if grep -q "ERROR: Some Requests Remain" "${output_dir}/stdout.txt"; then
        return 1
    fi
}

run_backend \
    congestion_unaware \
    "${BUILD_DIR}/AstraSim_Analytical_Congestion_Unaware"
run_backend \
    congestion_aware \
    "${BUILD_DIR}/AstraSim_Analytical_Congestion_Aware"

echo "[$0] Ok."
