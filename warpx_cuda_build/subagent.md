# subagent.md — warpx_cuda_build

## 目录目的
本目录用于在 WSL2 中构建和验证 CUDA/GPU 版 WarpX，并保存一个可复用的 GPU 示例算例。

## 维护规则
- 本文件记录 `warpx_cuda_build/` 内部主要变化。
- 外层总览记录维护在 `../agent.md`。
- 更深层目录不强制维护 `subagent.md`。

## 当前结构
- `src/`：本地 WarpX 源码克隆，不推送 GitHub。
- `envs/`：本地 CUDA 构建环境，不推送 GitHub。
- `build/`：CMake/Ninja 构建输出，不推送 GitHub。
- `logs/`：配置、编译和运行日志，默认不推送 GitHub。
- `examples/gpu_langmuir_2d/`：CUDA 版 2D Langmuir wave smoke test 输入文件。
- `scripts/`：CUDA 算例运行脚本与日志摘要绘图脚本。
- `runs/`：本地运行输出，不推送 GitHub。
- `visualizations/`：GPU 运行摘要图片。
- `docs/`：构建说明与验证记录。

## 主要变更
- 2026-05-26：创建 CUDA/GPU WarpX 构建目录。
- 2026-05-26：在 WSL2 内确认 NVIDIA GeForce RTX 2050 可见，显存 4096 MiB。
- 2026-05-26：创建 `envs/cuda-build`，安装 CMake、Ninja、GCC 与 CUDA 12.1 相关构建包。
- 2026-05-26：克隆 WarpX 26.04 源码到 `src/WarpX`，配置 2D CUDA、NOMPI、OpenPMD、非 Python app 构建。
- 2026-05-26：成功编译 `build/warpx-2d-cuda/bin/warpx.2d.NOMPI.CUDA.DP.PDP.OPMD.EB`。
- 2026-05-26：新增 `examples/gpu_langmuir_2d/inputs` 和 `scripts/run_cuda_langmuir_2d.sh`，已实际运行 60 步 GPU Langmuir 算例。
- 2026-05-26：新增 `scripts/plot_cuda_run_summary.py`，生成 `visualizations/cuda_langmuir_run_summary.png`。
- 2026-05-26：整理 `docs/build_notes.md`，记录官方依据、构建命令、运行结果和显存摘要。
- 2026-05-26：新增 `README.md` 和 `scripts/build_warpx_cuda_2d.sh`，方便从 GitHub 克隆后重建 CUDA WarpX。
