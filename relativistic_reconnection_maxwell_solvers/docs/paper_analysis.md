# 论文解析：Relativistic Magnetic Reconnection with Advanced Maxwell Solvers

## 论文信息

- 题目：Particle-in-cell Simulations of Relativistic Magnetic Reconnection with Advanced Maxwell Solver Algorithms
- arXiv：`2304.10566`
- 本地 PDF：`relativistic_reconnection_maxwell_solvers/paper/2304.10566.pdf`
- 本地文本提取：`relativistic_reconnection_maxwell_solvers/paper/2304.10566.txt`
- 代码/数据线索：论文正文提到输入文件和分析可在 Zenodo DOI `10.5281/zenodo.7847375` 获得。

## 研究问题

论文关注一个具体数值问题：在相对论磁重联 PIC 模拟中，传统 Yee FDTD Maxwell solver 是否可以被更先进的 Maxwell solver 替代，并获得相同物理结果和更高性能？

比较对象：

1. **Yee FDTD**：标准有限差分时域 Maxwell solver。
2. **CKC**：Cole-Kärkkäinen 非标准有限差分 solver，使用 Cowan 系数。
3. **PSATD**：Pseudo-Spectral Analytical Time Domain，文中使用 16 阶 stencil。
4. **PSATD + Esirkepov**：额外用于区分 Maxwell solver 与 current deposition 的性能影响。

论文核心结论：

- 对该相对论磁重联问题，CKC 和 PSATD 在能量转换、粒子加速、重联率、current sheet 结构上与 Yee 结果一致。
- CKC 和 PSATD 在相同网格下允许比 Yee 长约 $\sqrt{2}$ 的时间步；文中使用 CFL=0.95 时，CKC/PSATD 的时间步约比 Yee 长 40%。
- CKC 因每步成本接近 Yee，最终 time-to-solution 约快 40%。
- PSATD 的 Maxwell solve 本身不贵，但与 Vay current deposition 搭配时每步更慢，性能收益较小。
- PSATD 理论上 Maxwell solve 无 CFL 稳定上限，但物理准确性仍限制时间步；该问题中 CFL $\lesssim 1.65$ 到 $1.7$ 较可靠，更大 CFL 会出现能量非守恒。

## 物理模型

论文模拟的是二维电子-正电子 pair plasma 的双 Harris current sheet 重联。

### 双 Harris 片密度

论文定义每个物种的数密度为

$$
n(x) = n_b + (n_d-n_b)\left[\operatorname{sech}\left(\frac{x+x_c}{\delta}\right)+\operatorname{sech}\left(\frac{x-x_c}{\delta}\right)\right].
$$

其中：

- $n_b$：背景密度；
- $n_d$：current sheet 中心密度；
- $n_d/n_b = 5$；
- $\delta = 12.15\rho_c$：current sheet 半宽；
- current sheets 位于 $x=\pm x_c$。

### 漂移速度

正电子速度为 $+\beta(x)\hat{y}$，电子速度为 $-\beta(x)\hat{y}$：

$$
\boldsymbol{\beta}(x)
= \beta_0
\left[\operatorname{sech}\left(\frac{x-x_c}{\delta}\right)
- \operatorname{sech}\left(\frac{x+x_c}{\delta}\right)\right]\hat{y}.
$$

论文给出 $\beta_0 = 0.22c$。

### 磁场

远离 current sheets 时，上游磁场为

$$
\boldsymbol{B}=\pm B_0\hat{z}.
$$

磁场在 current sheet 处翻转，并由 Ampere 定律与漂移电流平衡：

$$
-\frac{\partial B_z}{\partial x} = 2\mu_0 e n(x)\beta(x)c.
$$

论文附录给出解析积分表达式，并通过矢势扰动初始化磁场，保证初始 $\nabla\cdot\boldsymbol{B}=0$。

### 触发重联的扰动

论文给矢势加入 1% 正弦扰动，用于控制 X 点位置和数量。本文地复现代码保留这一思想，在磁通函数等值线中加入 1% 代理扰动来展示 tearing/reconnection seed。

## 关键参数

论文 Table 1 的归一化参数：

| 参数 | 符号 | 值 |
|---|---:|---:|
| 背景冷磁化 | $\sigma$ | 30 |
| 背景温度 | $\theta_b$ | 0.15 |
| current sheet 半宽 | $\delta$ | $12.15\rho_c$ |
| current sheet skin depth | $\lambda_e$ | $2.45\rho_c$ |
| 过密度 | $n_d/n_b$ | 5 |
| current sheet drift | $\beta_0$ | $0.22c$ |
| current sheet 温度 | $\theta_d$ | 1.57 |
| domain half-width x | $L_x$ | $2195\rho_c$ |
| domain half-width z | $L_z$ | $1058\rho_c$ |

论文数值设置：

- 网格：$\Delta x=\Delta z=\lambda_e/4$；
- 分辨率：`7168 x 3456`；
- 每物种每 cell 粒子数：64；
- 总粒子数：约 31 亿；
- 边界条件：所有边界周期；
- 粒子形函数：cubic splines；
- current smoothing：single-pass bilinear filter；
- pusher：relativistic second-order Boris push。

## Maxwell solver 对比

在二维方形网格上，论文写出的稳定时间步尺度为：

$$
\Delta t_{C,\mathrm{Yee}} = \frac{\Delta x}{c\sqrt{2}},
$$

$$
\Delta t_{C,\mathrm{CKC}} = \frac{\Delta x}{c}.
$$

PSATD 对 Maxwell solve 本身没有有限差分 CFL 稳定上限；WarpX 默认可取类似 $\Delta x/c$ 的 Courant-like 时间步。论文统一用 CFL factor 定义实际时间步：

$$
\Delta t = \mathrm{CFL}\times\Delta t_C.
$$

论文 Table 2 报告：

| solver | time step | walltime/step | walltime to solution |
|---|---:|---:|---:|
| Yee | 0.411 | 0.077 | 274.6 |
| CKC | 0.581 | 0.077 | 193.5 |
| PSATD (+ Vay) | 0.581 | 0.115 | 290.0 |
| PSATD + Esirkepov | 0.581 | 0.083 | 209.9 |

这说明性能瓶颈主要在 current deposition，而不是 Maxwell field solve。

## 重联率

论文用近似

$$
\beta \approx \frac{v_{in}}{v_{out}}
$$

估计无量纲重联率。结果显示不同 Maxwell solver 的重联率演化非常接近：先上升到约 0.2，随后在 0.15–0.2 附近维持一段时间，再因周期边界和重联前沿相互干扰而下降。

## 大时间步 PSATD 结果

PSATD 在 Maxwell solve 意义下无 CFL 稳定上限，但粒子运动、沉积、场-粒子耦合仍会限制准确性。论文发现：

- CFL $\le 1.6$：能量非守恒较小，结果与基准接近；
- CFL $\approx 1.65$：末期开始出现增长但仍较可控；
- CFL $\approx 1.7$：主要重联阶段仍能保持接近；
- CFL $\ge 1.8$：能量误差更早发展，后期粒子能谱和能量转换偏离明显。

## 本地复现定位

完整 PIC 复现需要 GPU 集群和论文级粒子数。本目录实现的是缩小版复现：复现初值公式、关键参数、solver 时间步差异、性能表和趋势图，而不是完整 kinetic PIC 动力学。
