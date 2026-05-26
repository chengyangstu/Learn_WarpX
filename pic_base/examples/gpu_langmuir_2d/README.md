# GPU-ready 2D Langmuir 示例

这个示例用于测试 WarpX GPU 后端是否能正常运行。输入文件本身不依赖 CPU/GPU；真正决定是否上 GPU 的是 WarpX 可执行文件的构建后端。

当前 conda-forge 安装的 WarpX 是 `NOMPI.OMP` CPU/OpenMP 版本，因此本机目前只能用它做 CPU 功能验证。如果以后换成 CUDA/HIP 版 WarpX，同一个输入文件可以直接用于 GPU smoke test。

## 检查后端

```bash
./pic_base/scripts/check_warpx_gpu_backend.sh
```

## 运行

CPU/OpenMP 验证：

```bash
./pic_base/scripts/run_gpu_langmuir_2d.sh
```

如果你有 CUDA/HIP 版 WarpX，可指定二进制：

```bash
WARPX_2D_BIN=/path/to/warpx.2d ./pic_base/scripts/run_gpu_langmuir_2d.sh
```

## 输出

输出目录：`pic_base/runs/gpu_langmuir_2d/`。
