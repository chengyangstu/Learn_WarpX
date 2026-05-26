#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
DEFAULT_BIN="$BASE_DIR/build/warpx-2d-cuda/bin/warpx.2d.NOMPI.CUDA.DP.PDP.OPMD.EB"
WARPX_2D_BIN=${WARPX_2D_BIN:-$DEFAULT_BIN}
INPUT_FILE="$BASE_DIR/examples/gpu_langmuir_2d/inputs"
RUN_DIR="$BASE_DIR/runs/gpu_langmuir_2d"

if [[ ! -x "$WARPX_2D_BIN" ]]; then
  echo "CUDA WarpX binary not executable: $WARPX_2D_BIN" >&2
  echo "Build it first or set WARPX_2D_BIN=/path/to/warpx.2d.NOMPI.CUDA..." >&2
  exit 1
fi

rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR"
cp "$INPUT_FILE" "$RUN_DIR/inputs"

cd "$RUN_DIR"
"$WARPX_2D_BIN" inputs | tee run.log

printf '\nCUDA WarpX run complete. Outputs are in %s\n' "$RUN_DIR"
if grep -Eq 'Initializing CUDA|CUDA initialized|Device Memory Usage|Total GPU global memory' run.log; then
  echo "Confirmed CUDA/GPU execution markers in run.log."
else
  echo "WARNING: CUDA/GPU markers were not found in run.log." >&2
fi
