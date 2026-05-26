# WarpX GPU 运行说明

## 当前机器状态

本机能看到一块 NVIDIA GPU：GeForce RTX 2050，显存约 4 GB。`nvidia-smi` 可用，说明驱动侧可见 GPU。

但当前 `pic_base/envs/warpx` 中的 conda-forge WarpX 是 CPU/OpenMP 构建：

```text
warpx.2d.NOMPI.OMP.DP.PDP.OPMD.FFT.EB.QED
```

其中 `OMP` 表示 OpenMP CPU 后端，名称中没有 `CUDA`、`HIP` 或 `SYCL`。因此当前环境不能真正把 WarpX 计算放到 GPU 上。

## 已建立的 GPU-ready 算例

- 输入文件：`pic_base/examples/gpu_langmuir_2d/inputs`
- 检查脚本：`pic_base/scripts/check_warpx_gpu_backend.sh`
- 运行脚本：`pic_base/scripts/run_gpu_langmuir_2d.sh`

该输入是 2D Langmuir 波小算例，规模适合做 GPU smoke test。输入文件本身 CPU/GPU 通用，是否上 GPU 取决于 `warpx.2d` 的构建后端。

## 当前可做的验证

```bash
./pic_base/scripts/check_warpx_gpu_backend.sh
./pic_base/scripts/run_gpu_langmuir_2d.sh
```

这会用当前 CPU/OpenMP WarpX 运行同一个算例，确认输入文件正确。

## 真正 GPU 运行需要什么

需要一个 CUDA/HIP/SYCL 构建的 WarpX 二进制。例如 CUDA 版通常需要：

- NVIDIA driver；
- CUDA Toolkit，包含 `nvcc`；
- CMake；
- 从 WarpX 源码用 GPU 后端构建。

构建成功后，用如下方式指定 GPU 版二进制：

```bash
WARPX_2D_BIN=/path/to/cuda/warpx.2d ./pic_base/scripts/run_gpu_langmuir_2d.sh
```

如果二进制是 CUDA/HIP/SYCL 后端，WarpX/AMReX 日志通常会显示对应 GPU backend 信息。

## 本次运行结果

已执行：

```bash
./pic_base/scripts/check_warpx_gpu_backend.sh
./pic_base/scripts/run_gpu_langmuir_2d.sh
```

结果：

- 机器能看到 NVIDIA GeForce RTX 2050。
- 当前 WarpX 二进制为 CPU/OpenMP 后端，运行日志显示 `OMP initialized with 10 OMP threads`，未显示 CUDA/HIP/SYCL/GPU 后端。
- 2D Langmuir 输入文件运行成功，输出目录为 `pic_base/runs/gpu_langmuir_2d/`。
- 这次运行用于验证 GPU-ready 输入文件正确；它不是一次真正的 GPU WarpX 计算。

如果后续安装或编译 CUDA 版 WarpX，只需设置：

```bash
WARPX_2D_BIN=/path/to/cuda/warpx.2d ./pic_base/scripts/run_gpu_langmuir_2d.sh
```
