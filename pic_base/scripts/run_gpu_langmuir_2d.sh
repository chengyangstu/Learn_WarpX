#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PIC_BASE=$(cd -- "$SCRIPT_DIR/.." && pwd)
ENV_PREFIX="$PIC_BASE/envs/warpx"
MICROMAMBA="$PIC_BASE/tools/bin/micromamba"
RUN_DIR="$PIC_BASE/runs/gpu_langmuir_2d"
INPUT_FILE="$PIC_BASE/examples/gpu_langmuir_2d/inputs"
WARPX_2D_BIN=${WARPX_2D_BIN:-$ENV_PREFIX/bin/warpx.2d}

if [[ ! -x "$WARPX_2D_BIN" ]]; then
  echo "WarpX 2D binary not executable: $WARPX_2D_BIN" >&2
  echo "Set WARPX_2D_BIN=/path/to/gpu-enabled/warpx.2d if using a custom GPU build." >&2
  exit 1
fi

rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR"
cp "$INPUT_FILE" "$RUN_DIR/inputs"

cd "$RUN_DIR"
if [[ "$WARPX_2D_BIN" == "$ENV_PREFIX"/* && -x "$MICROMAMBA" ]]; then
  "$MICROMAMBA" run -p "$ENV_PREFIX" "$WARPX_2D_BIN" inputs | tee run.log
else
  "$WARPX_2D_BIN" inputs | tee run.log
fi

printf '\nRun complete. Outputs are in %s\n' "$RUN_DIR"
if grep -Eiq 'CUDA|HIP|SYCL|GPU' run.log; then
  echo "Run log advertises a GPU backend."
else
  echo "Run log does not advertise GPU backend; this was likely CPU/OpenMP unless your custom build hides backend tags."
fi
