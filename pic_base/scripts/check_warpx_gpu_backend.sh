#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PIC_BASE=$(cd -- "$SCRIPT_DIR/.." && pwd)
ENV_PREFIX="$PIC_BASE/envs/warpx"
MICROMAMBA="$PIC_BASE/tools/bin/micromamba"
WARPX_2D_BIN=${WARPX_2D_BIN:-$ENV_PREFIX/bin/warpx.2d}

echo "== GPU device check =="
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader || nvidia-smi
else
  echo "nvidia-smi not found"
fi
if command -v rocm-smi >/dev/null 2>&1; then
  rocm-smi || true
fi

echo
echo "== WarpX binary =="
echo "$WARPX_2D_BIN"
if [[ ! -x "$WARPX_2D_BIN" ]]; then
  echo "WarpX binary not executable. Set WARPX_2D_BIN=/path/to/warpx.2d" >&2
  exit 1
fi

binary_name=$(basename "$(readlink -f "$WARPX_2D_BIN")")
echo "Resolved binary name: $binary_name"

if [[ "$binary_name" == *CUDA* || "$binary_name" == *HIP* || "$binary_name" == *SYCL* || "$binary_name" == *GPU* ]]; then
  echo "Likely GPU-enabled WarpX binary."
else
  echo "This binary name does not advertise CUDA/HIP/SYCL. It is likely CPU/OpenMP."
fi

echo
echo "== Installed conda package tags =="
if [[ -x "$MICROMAMBA" ]]; then
  "$MICROMAMBA" list -p "$ENV_PREFIX" | grep -E 'warpx|amrex|cuda|hip|mpi' || true
else
  echo "micromamba not found at $MICROMAMBA"
fi

echo
echo "== Build hint =="
echo "conda-forge WarpX packages are CPU/OpenMP in this environment."
echo "For actual GPU execution, build WarpX from source with CUDA/HIP/SYCL and set WARPX_2D_BIN to that executable."
