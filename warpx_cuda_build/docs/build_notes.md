# CUDA/GPU WarpX 构建与算例记录

## 目录目的

`warpx_cuda_build/` 是一个真正面向 NVIDIA GPU 的 WarpX 本地构建与验证目录。它和 `pic_base/` 中的 conda-forge CPU/OpenMP 环境分开，避免把 CPU 包误认为 GPU 版。

## 官方依据

WarpX 官方 CMake 文档说明：

- CMake 是 WarpX 的主要构建系统；
- NVIDIA GPU 后端通过 `-DWarpX_COMPUTE=CUDA` 启用；
- 维度通过 `-DWarpX_DIMS=2` 或 `-DWarpX_DIMS="1;2;3;RZ"` 等设置；
- GPU 构建需要 CUDA Toolkit 与相应依赖。

官方入口：

- <https://warpx.readthedocs.io/en/latest/install/cmake.html>
- <https://warpx.readthedocs.io/en/latest/install/dependencies.html>

## 本机 GPU 状态

2026-05-26 在 WSL2 内确认：

```text
NVIDIA GeForce RTX 2050, 4096 MiB, driver 531.88
```

`nvidia-smi` 可用，说明 WSL2 可以访问本机 NVIDIA GPU。之前 `pic_base/envs/warpx` 中的 conda-forge WarpX 是 CPU/OpenMP 版，不含 CUDA 后端。

## 构建环境

本目录使用本地 micromamba 环境：

```bash
warpx_cuda_build/envs/cuda-build
```

主要包：

```text
cmake, ninja, git, make, pkg-config, gxx_linux-64,
cuda-nvcc, cuda-cudart-dev, cuda-libraries-dev, cuda-nvtx-dev, cuda-version=12.1
```

源码：

```text
warpx_cuda_build/src/WarpX
WarpX 26.04, commit faffce0
```

构建目录：

```text
warpx_cuda_build/build/warpx-2d-cuda
```

## CMake 配置

实际可复用命令如下：

```bash
cmake -S warpx_cuda_build/src/WarpX \
  -B warpx_cuda_build/build/warpx-2d-cuda \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DWarpX_DIMS=2 \
  -DWarpX_COMPUTE=CUDA \
  -DCMAKE_CUDA_ARCHITECTURES=86 \
  -DWarpX_MPI=OFF \
  -DWarpX_OPENPMD=ON \
  -DWarpX_QED=OFF \
  -DWarpX_APP=ON \
  -DWarpX_PYTHON=OFF
```

配置日志确认：

```text
COMPUTE: CUDA
DIMS: 2
MPI: OFF
OPENPMD: ON
QED: OFF
APP: ON
```

## 编译

编译命令：

```bash
./pic_base/tools/bin/micromamba run \
  -p warpx_cuda_build/envs/cuda-build \
  cmake --build warpx_cuda_build/build/warpx-2d-cuda --parallel 2
```

成功生成：

```text
warpx_cuda_build/build/warpx-2d-cuda/bin/warpx.2d.NOMPI.CUDA.DP.PDP.OPMD.EB
```

二进制大小约 557 MB。文件名中的 `CUDA` 表示这是 CUDA 后端构建。

## GPU 算例

新增 2D Langmuir wave GPU smoke test：

```text
warpx_cuda_build/examples/gpu_langmuir_2d/inputs
```

运行脚本：

```bash
./warpx_cuda_build/scripts/run_cuda_langmuir_2d.sh
```

脚本默认使用本目录编译出的 CUDA 二进制，也可以覆盖：

```bash
WARPX_2D_BIN=/path/to/warpx.2d.NOMPI.CUDA... \
  ./warpx_cuda_build/scripts/run_cuda_langmuir_2d.sh
```

运行输出：

```text
warpx_cuda_build/runs/gpu_langmuir_2d/run.log
warpx_cuda_build/runs/gpu_langmuir_2d/diags/
```

## GPU 运行验证

2026-05-26 已实际运行完成，日志关键标记：

```text
Initializing CUDA...
CUDA initialized with 1 device.
Device Memory Usage:
Total GPU global memory (MB): 4095
[The         Arena] max space allocated (MB): 3071
[The         Arena] max space used      (MB): 10
```

这说明算例确实通过 CUDA WarpX 在 GPU 后端运行。该小算例计算量很小，因此 GPU arena 预分配较大，但真实使用量约 10 MB。

## 可视化

新增日志摘要可视化脚本：

```bash
./pic_base/tools/bin/micromamba run \
  -p pic_base/envs/warpx \
  python warpx_cuda_build/scripts/plot_cuda_run_summary.py
```

生成图片：

```text
warpx_cuda_build/visualizations/cuda_langmuir_run_summary.png
```

图中左侧为每步耗时与平均耗时，右侧为 AMReX 报告的 GPU 显存摘要。

## 注意事项

- `envs/`、`build/`、`src/WarpX/` 和 `runs/` 都是本地可再生的大目录，不应推送到 GitHub。
- GitHub 中保留输入文件、脚本、文档和可视化结果；本地机器保留完整构建产物。
- 如果更换 GPU，需要按新显卡调整 `CMAKE_CUDA_ARCHITECTURES`。
