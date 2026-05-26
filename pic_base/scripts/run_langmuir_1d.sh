#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PIC_BASE=$(cd -- "$SCRIPT_DIR/.." && pwd)
REPO_ROOT=$(cd -- "$PIC_BASE/.." && pwd)
MICROMAMBA="$PIC_BASE/tools/bin/micromamba"
ENV_PREFIX="$PIC_BASE/envs/warpx"
RUN_DIR="$PIC_BASE/runs/langmuir_1d"
INPUT_FILE="$PIC_BASE/examples/langmuir_1d/inputs"

if [[ ! -x "$MICROMAMBA" ]]; then
  echo "micromamba not found at $MICROMAMBA" >&2
  exit 1
fi

rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR"
cp "$INPUT_FILE" "$RUN_DIR/inputs"

cd "$RUN_DIR"
"$MICROMAMBA" run -p "$ENV_PREFIX" warpx.1d inputs | tee run.log

printf '\nRun complete. Outputs are in %s\n' "$RUN_DIR"
