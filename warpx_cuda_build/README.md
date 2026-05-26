# CUDA/GPU WarpX 示例目录

本目录用于构建并验证 NVIDIA CUDA 版 WarpX。当前本机已经在 WSL2 中成功编译并运行 2D CUDA WarpX。

## 已验证结果

- GPU：NVIDIA GeForce RTX 2050，4096 MiB 显存。
- WarpX：26.04。
- 构建：`2D + CUDA + NOMPI + OpenPMD`。
- 二进制：`warpx_cuda_build/build/warpx-2d-cuda/bin/warpx.2d.NOMPI.CUDA.DP.PDP.OPMD.EB`。
- 算例：`examples/gpu_langmuir_2d/inputs`。
- 运行脚本：`scripts/run_cuda_langmuir_2d.sh`。
- 可视化：`visualizations/cuda_langmuir_run_summary.png`。

## 快速运行

如果本地构建产物还在，直接运行：

```bash
./warpx_cuda_build/scripts/run_cuda_langmuir_2d.sh
```

重新生成日志摘要图：

```bash
./pic_base/tools/bin/micromamba run \
  -p pic_base/envs/warpx \
  python warpx_cuda_build/scripts/plot_cuda_run_summary.py
```

## 重新构建

本地构建环境、源码和构建产物体积较大，不推送到 GitHub。需要重建时运行：

```bash
./warpx_cuda_build/scripts/build_warpx_cuda_2d.sh
```

详细记录见：`docs/build_notes.md`。
