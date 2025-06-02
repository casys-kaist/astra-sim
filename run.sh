#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath $0)")
#./build/astra_analytical/build/AnalyticalAstra/bin/AnalyticalAstra
BINARY="${SCRIPT_DIR:?}"/build/astra_analytical/build/AnalyticalAstra/bin/AnalyticalAstra
#./inputs/custom_workload/llm
WORKLOAD="${SCRIPT_DIR:?}"/inputs/workload/RTX3090_gpt3-6.7b_batch0/llm
#./inputs/system/sample_fully_connected_sys.txt
SYSTEM="${SCRIPT_DIR:?}"/inputs/system/system.json
#./inputs/network/analytical/fully_connected.json
NETWORK="${SCRIPT_DIR:?}"/inputs/network/network.yml
#./inputs/remote_memory/analytical/per_npu_memory_expansion.json
MEMORY="${SCRIPT_DIR:?}"/inputs/remote_memory/per_npu_memory_expansion.json

# running version
"${BINARY}" \
  --workload-configuration="${WORKLOAD}" \
  --system-configuration="${SYSTEM}" \
  --network-configuration="${NETWORK}"\
  --remote-memory-configuration="${MEMORY}"
