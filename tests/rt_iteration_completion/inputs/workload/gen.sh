#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")

cd "${SCRIPT_DIR}"
python3 "${SCRIPT_DIR}/gen_chakra_traces.py"
