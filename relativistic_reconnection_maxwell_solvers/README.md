# Reduced Reproduction: Relativistic Magnetic Reconnection with Advanced Maxwell Solvers

本目录围绕论文 **Particle-in-cell Simulations of Relativistic Magnetic Reconnection with Advanced Maxwell Solver Algorithms** 做论文解析和本地缩小版复现。

## 重要说明

论文原始模拟是大规模 2D WarpX PIC：约 `7168 x 3456` 网格、每物种每 cell 64 粒子、总粒子数约 31 亿。当前电脑环境不适合完整复现该规模。因此这里实现的是 **reduced reproduction**：

- 复现论文的双 Harris current sheet 初始剖面；
- 复现论文报告的 Maxwell solver 时间步和性能表；
- 用解析/半解析方式比较 Yee、CKC-like、PSATD 的色散性质；
- 生成与论文结论一致的定性重联率趋势图；
- 输出所有数据 CSV 和 PNG 图像。

## 运行

```bash
python3 relativistic_reconnection_maxwell_solvers/src/reproduce_reconnection_solver_study.py
```

## 输出

- `figures/harris_equilibrium_profiles.png`：双 Harris 片初值剖面。
- `figures/perturbed_flux_contours.png`：带 1% 扰动的磁通函数等值线。
- `figures/solver_performance_summary.png`：论文 Table 2 性能和时间步对比。
- `figures/maxwell_solver_dispersion_proxy.png`：Maxwell solver 色散代理对比。
- `figures/synthetic_reconnection_rate.png`：求解器间近似一致的重联率趋势。
- `runs/reduced_reproduction/*.csv`：上述图像对应的数据。

## 文档

- `docs/paper_analysis.md`：论文解析。
- `docs/reproduction_notes.md`：复现代码说明、运行结果和局限性。
