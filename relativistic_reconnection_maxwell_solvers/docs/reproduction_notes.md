# 缩小版复现说明

## 运行命令

```bash
python3 relativistic_reconnection_maxwell_solvers/src/reproduce_reconnection_solver_study.py
```

运行已在本地完成，生成输出：

```text
relativistic_reconnection_maxwell_solvers/runs/reduced_reproduction/
relativistic_reconnection_maxwell_solvers/figures/
```

## 复现代码做了什么

脚本：`relativistic_reconnection_maxwell_solvers/src/reproduce_reconnection_solver_study.py`

实现内容：

1. 定义论文 Table 1 的核心参数：$\sigma=30$、$\delta=12.15\rho_c$、$\lambda_e=2.45\rho_c$、$n_d/n_b=5$、$\beta_0=0.22$、$L_x=2195\rho_c$、$L_z=1058\rho_c$。
2. 构造双 Harris current sheet 的 $n(x)$、$\beta_y(x)$。
3. 由一维 Ampere-law 关系数值积分得到归一化 $B_z/B_0$，并强制满足 current sheet 内外磁场翻转拓扑。
4. 构造 1% 扰动的磁通函数等值线，用来模拟论文中用于触发重联的 perturbation 思想。
5. 根据论文时间步关系计算 Yee、CKC、PSATD 的时间步比例，并复现 Table 2 报告的性能比较。
6. 用解析色散代理展示 Yee、CKC-like、PSATD 的 Maxwell solver 色散差异。
7. 生成与论文 Figure 6 结论一致的定性重联率趋势：不同 solver 的 $v_{in}/v_{out}$ 曲线基本重合，并在 0.15–0.2 附近形成平台。

## 生成图像

- `figures/harris_equilibrium_profiles.png`：双 Harris 片的 $B_z/B_0$、$n/n_b$、$\beta_y$ 剖面。
- `figures/perturbed_flux_contours.png`：带 1% 扰动的磁通函数等值线。
- `figures/solver_performance_summary.png`：论文 Table 2 的时间步比例和 time-to-solution speedup。
- `figures/maxwell_solver_dispersion_proxy.png`：Yee、CKC-like、PSATD 色散性质对比。
- `figures/synthetic_reconnection_rate.png`：solver-independent 重联率趋势复现。

## 生成数据

- `runs/reduced_reproduction/harris_profiles.csv`
- `runs/reduced_reproduction/solver_performance_table.csv`
- `runs/reduced_reproduction/dispersion_proxy.csv`
- `runs/reduced_reproduction/synthetic_reconnection_rate.csv`

## 运行结果摘要

本地运行打印：

```text
Reduced reproduction complete
Key paper-scale values:
  dx = lambda_e/4 = 0.6125 rho_c
  Yee dt(CFL=0.95) = 0.411 omega_c^-1
  CKC/PSATD dt(CFL=0.95) = 0.582 omega_c^-1
  dt ratio = 1.414
```

其中 $1.414\approx\sqrt{2}$，对应论文中 CKC/PSATD 相比 Yee 可用约 40% 更长时间步的结论。

## 与完整论文复现的差别

这不是完整 WarpX PIC 生产级复现，原因：

- 论文原模拟约 31 亿粒子，需要 GPU 集群；
- 当前代码没有推进粒子分布函数，也没有自洽 Maxwell-PIC 耦合；
- 重联率曲线是根据论文报告趋势构造的定性代理，不是由 kinetic PIC 动力学直接产生；
- CKC 色散曲线是 non-standard FDTD 的简化代理，不是 WarpX CKC 内核逐项实现。

因此本复现适合用于：

- 学习论文物理设置；
- 验证关键尺度和时间步关系；
- 理解为什么 CKC/PSATD 可用更长时间步；
- 生成论文讲解用的本地图表。

若要进一步逼近完整复现，下一步应使用 WarpX 写一个小网格 2D Harris sheet PIC 输入，分别跑 Yee/CKC/PSATD，并用 openPMD 后处理真实 $B_z$、$J_y$、粒子能谱和能量守恒。
