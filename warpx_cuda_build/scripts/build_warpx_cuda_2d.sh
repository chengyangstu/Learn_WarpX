#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
REPO_DIR=$(cd -- "$BASE_DIR/.." && pwd)
MICROMAMBA="$REPO_DIR/pic_base/tools/bin/micromamba"
ENV_PREFIX="$BASE_DIR/envs/cuda-build"
SRC_DIR="$BASE_DIR/src/WarpX"
BUILD_DIR="$BASE_DIR/build/warpx-2d-cuda"
LOG_DIR="$BASE_DIR/logs"
CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES:-86}
WARPX_REF=${WARPX_REF:-26.04}

if [[ ! -x "$MICROMAMBA" ]]; then
  echo "micromamba not found at $MICROMAMBA" >&2
  echo "Install/recover pic_base/tools/bin/micromamba first." >&2
  exit 1
fi

mkdir -p "$BASE_DIR/envs" "$BASE_DIR/src" "$BUILD_DIR" "$LOG_DIR"

if [[ ! -d "$SRC_DIR/.git" ]]; then
  git clone --branch "$WARPX_REF" --depth 1 https://github.com/ECP-WarpX/WarpX.git "$SRC_DIR"
fi

"$MICROMAMBA" create -y -p "$ENV_PREFIX" -c conda-forge \
  cmake ninja git make pkg-config gxx_linux-64 \
  cuda-nvcc cuda-cudart-dev cuda-libraries-dev cuda-nvtx-dev cuda-version=12.1

"$MICROMAMBA" run -p "$ENV_PREFIX" cmake -S "$SRC_DIR" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DWarpX_DIMS=2 \
  -DWarpX_COMPUTE=CUDA \
  -DCMAKE_CUDA_ARCHITECTURES="$CUDA_ARCHITECTURES" \
  -DWarpX_MPI=OFF \
  -DWarpX_OPENPMD=ON \
  -DWarpX_QED=OFF \
  -DWarpX_APP=ON \
  -DWarpX_PYTHON=OFF 2>&1 | tee "$LOG_DIR/cmake_configure.log"

"$MICROMAMBA" run -p "$ENV_PREFIX" cmake --build "$BUILD_DIR" --parallel "${BUILD_PARALLEL:-2}" 2>&1 | tee "$LOG_DIR/build.log"

find "$BUILD_DIR/bin" -maxdepth 1 -type f -perm -111 -name 'warpx.2d*' -print
