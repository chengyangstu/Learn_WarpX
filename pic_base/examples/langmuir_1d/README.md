# Langmuir 1D 示例

这是一个轻量化的 WarpX 1D Langmuir 波算例，用电子-正电子等离子体的微小速度扰动激发等离子体振荡。

## 运行

从仓库根目录执行：

```bash
./pic_base/scripts/run_langmuir_1d.sh
```

运行输出写入 `pic_base/runs/langmuir_1d/`，其中 `diags/diag1*` 是 WarpX plotfile，`diags/openpmd/` 是 openPMD 诊断输出。

## 可视化

运行完成后可生成 `Ez` 和 `rho` 随空间变化的对比图：

```bash
./pic_base/envs/warpx/bin/python pic_base/scripts/plot_langmuir_1d.py
```

图片输出：`pic_base/visualizations/langmuir_1d_fields.png`。
