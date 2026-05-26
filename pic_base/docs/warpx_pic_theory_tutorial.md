# WarpX PIC 理论教程整理

> 整理依据：WarpX 官方文档的 Theory 章节，重点参考 `Theory and Algorithms`、`Electromagnetic Particle-In-Cell`、`Explicit EM-PIC`、粒子推进、场求解、沉积与诊断相关页面。本文按官网教程的表达习惯整理：物理方程使用 LaTeX 数学环境，WarpX 输入参数、命令和伪代码使用代码块。

## 1. WarpX 要解决的方程

WarpX 是面向等离子体和束流物理的高性能 Particle-In-Cell（PIC）代码。PIC 方法的目标是用宏粒子和网格场近似求解 Vlasov-Maxwell 系统。

对第 $s$ 个粒子物种，分布函数 $f_s(\boldsymbol{x}, \boldsymbol{u}, t)$ 的无碰撞演化可写为

$$
\frac{\partial f_s}{\partial t}
+ \boldsymbol{v}\cdot \nabla_{\boldsymbol{x}} f_s
+ \frac{q_s}{m_s}
\left(\boldsymbol{E} + \boldsymbol{v}\times\boldsymbol{B}\right)
\cdot \nabla_{\boldsymbol{u}} f_s = 0 .
$$

电磁场满足 Maxwell 方程组

$$
\nabla \cdot \boldsymbol{E} = \frac{\rho}{\epsilon_0},
\qquad
\nabla \cdot \boldsymbol{B} = 0,
$$

$$
\frac{\partial \boldsymbol{B}}{\partial t} = -\nabla\times\boldsymbol{E},
\qquad
\frac{\partial \boldsymbol{E}}{\partial t}
= c^2 \nabla\times\boldsymbol{B} - \frac{\boldsymbol{J}}{\epsilon_0} .
$$

源项由所有粒子物种贡献：

$$
\rho = \sum_s \rho_s,
\qquad
\boldsymbol{J} = \sum_s \boldsymbol{J}_s .
$$

直接在完整相空间上求解 $f_s$ 通常非常昂贵。PIC 的核心思想是：用有限数量的宏粒子采样分布函数，用网格求解电磁场，再通过沉积和插值耦合粒子与场。

## 2. PIC 的基本近似

### 2.1 宏粒子表示分布函数

PIC 中，一个宏粒子代表许多真实粒子。第 $p$ 个宏粒子通常包含位置、动量、权重、电荷和质量：

$$
\left(\boldsymbol{x}_p, \boldsymbol{u}_p, w_p, q_p, m_p\right).
$$

粒子分布函数可近似写成宏粒子贡献的叠加：

$$
f_s(\boldsymbol{x}, \boldsymbol{u}, t)
\simeq
\sum_{p\in s} w_p\,
S_x\!\left(\boldsymbol{x}-\boldsymbol{x}_p(t)\right)
S_u\!\left(\boldsymbol{u}-\boldsymbol{u}_p(t)\right),
$$

其中 $S_x$ 是空间形函数。宏粒子不是严格的数学点，而是通过形函数在网格上有有限支撑。

### 2.2 网格场

电磁场 $\boldsymbol{E}$、$\boldsymbol{B}$，以及源项 $\rho$、$\boldsymbol{J}$ 存在计算网格上。PIC 每个时间步都会在两个表示之间来回转换：

```text
particles -> deposit rho,J -> solve grid fields -> gather E,B -> push particles
```

这种“粒子 + 网格”的混合方法兼顾了粒子法对相空间动力学的适应性，以及网格法求解 Maxwell 方程的效率。

## 3. 显式 EM-PIC 时间步

显式电磁 PIC 通常使用 leapfrog 时间交错：粒子位置在整数步，粒子动量在半整数步，电磁场按离散 Maxwell 方程推进。

一个典型时间推进可概括为：

```text
Given x_p^n, u_p^{n-1/2}, E^n, B^n
1. Deposit current J^{n+1/2} from particle trajectories
2. Advance Maxwell equations to obtain E^{n+1}, B^{n+1}
3. Gather E and B from mesh to particle positions
4. Push particle momentum to u_p^{n+1/2}
5. Push particle position to x_p^{n+1}
6. Apply boundary conditions and write diagnostics
```

其中粒子推进对应 Lorentz 力方程

$$
\frac{d\boldsymbol{p}}{dt}
= q\left(\boldsymbol{E} + \boldsymbol{v}\times\boldsymbol{B}\right),
\qquad
\frac{d\boldsymbol{x}}{dt} = \boldsymbol{v} .
$$

显式方法的优点是局部、直接、并行效率高；限制是时间步需要满足 CFL 稳定性条件。

## 4. 沉积：从粒子到网格

粒子电荷密度沉积到网格可写为

$$
\rho(\boldsymbol{x}_i)
= \sum_p q_p w_p\,
S\!\left(\boldsymbol{x}_i - \boldsymbol{x}_p\right),
$$

电流密度类似地写为

$$
\boldsymbol{J}(\boldsymbol{x}_i)
= \sum_p q_p w_p\,\boldsymbol{v}_p\,
S\!\left(\boldsymbol{x}_i - \boldsymbol{x}_p\right).
$$

实际电磁 PIC 中，电流沉积不仅要给出 $\boldsymbol{J}$，还要与离散连续性方程相容：

$$
\frac{\partial \rho}{\partial t} + \nabla\cdot\boldsymbol{J} = 0 .
$$

如果离散电荷守恒不好，Gauss 定律误差会随时间积累。当前示例使用 WarpX 的 Esirkepov 电流沉积：

```text
algo.current_deposition = esirkepov
```

它的重点是满足离散电荷守恒，适合显式 EM-PIC 入门学习。

## 5. 插值：从网格到粒子

粒子推进需要粒子位置处的电磁场。网格场到粒子的 gather 过程可写为

$$
\boldsymbol{E}_p
= \sum_i \boldsymbol{E}_i\,
S\!\left(\boldsymbol{x}_i - \boldsymbol{x}_p\right),
\qquad
\boldsymbol{B}_p
= \sum_i \boldsymbol{B}_i\,
S\!\left(\boldsymbol{x}_i - \boldsymbol{x}_p\right).
$$

WarpX 输入中，当前示例选择能量守恒型场插值：

```text
algo.field_gathering = energy-conserving
```

不同 gather 方式会影响能量守恒、动量守恒、噪声和稳定性。学习时建议先固定一种方式，理解 PIC 主流程后再比较不同选项。

## 6. 粒子形函数

形函数 $S$ 决定一个宏粒子在网格上的“云团”形状。低阶形函数成本低，高阶形函数通常更平滑、噪声更小。

当前算例使用一阶形函数：

```text
algo.particle_shape = 1
```

形函数阶数会同时影响：

- 电荷与电流沉积；
- 场插值；
- 数值噪声；
- 单步计算成本；
- 粒子跨网格时的平滑程度。

## 7. 场求解器

### 7.1 Yee FDTD

Yee FDTD 是经典显式电磁场求解器。它在空间和时间上交错放置电场与磁场分量，用 curl 方程推进：

$$
\boldsymbol{B}^{n+1/2} = \boldsymbol{B}^{n-1/2} - \Delta t\,\nabla\times\boldsymbol{E}^{n},
$$

$$
\boldsymbol{E}^{n+1}= \boldsymbol{E}^{n}+ c^2\Delta t\,\nabla\times\boldsymbol{B}^{n+1/2}- \frac{\Delta t}{\epsilon_0}\boldsymbol{J}^{n+1/2}.
$$

它的优点是局部 stencil、易并行、成本低，适合入门与大量工程问题。缺点是存在数值色散，尤其在相对论高速粒子与电磁波共传播问题中需要注意。

### 7.2 PSATD

PSATD 是谱类 Maxwell 求解器，在 Fourier 空间解析推进场。它可以显著降低数值色散，并常用于相对论束流、激光传播、boosted-frame 等场景。

PSATD 的代价是 FFT 和更全局的数据通信。初学建议先掌握 Yee FDTD，再学习 PSATD 的谱空间推进思想与并行代价。

## 8. 粒子推进器

粒子推进器离散求解 Lorentz 力方程。常见选择包括：

- **Boris pusher**：经典、稳定、体积保持，是 PIC 中最常见的默认选择之一。
- **Vay pusher**：更适合某些相对论漂移和 boosted-frame 场景。
- **Higuera-Cary pusher**：兼顾相对论一致性和较好的长期性质。

可以把 pusher 理解为对下面方程的时间中心化离散：

$$
\frac{d\boldsymbol{u}}{dt}
= \frac{q}{m}\left(\boldsymbol{E} + \boldsymbol{v}\times\boldsymbol{B}\right),
\qquad
\frac{d\boldsymbol{x}}{dt} = \boldsymbol{v}.
$$

当前入门算例保持 WarpX 默认粒子推进设置，重点是先理解完整 PIC 循环。

## 9. 边界条件

PIC 模拟中需要同时考虑场边界和粒子边界。常见场边界包括周期、导体、吸收边界和 PML；常见粒子边界包括周期、吸收、反射和注入。

当前 Langmuir 示例使用周期场边界：

```text
boundary.field_lo = periodic
boundary.field_hi = periodic
```

周期边界适合研究均匀无限等离子体中的基本波动；如果研究激光入射、开放边界或壁面效应，则需要换成更合适的边界条件。

## 10. 稳定性与误差来源

### 10.1 CFL 条件

显式 Maxwell 求解器的时间步受光速传播限制。形式上可理解为

$$
c\Delta t \lesssim C\Delta x,
$$

其中 $C$ 与维度和离散格式有关。当前示例设置：

```text
warpx.cfl = 0.8
```

### 10.2 PIC 噪声

PIC 是采样方法，有限宏粒子数会带来统计噪声。常见降噪方式包括：增加每个 cell 的粒子数、提高形函数阶数、使用滤波、更平滑的初始化等。

### 10.3 数值色散与数值加热

Yee FDTD 的数值相速度依赖网格和传播方向，可能引入数值色散。粗网格、低粒子数、过大时间步或不合适的插值/沉积组合也可能导致非物理自热。

## 11. AMR 与网格分解

WarpX 基于 AMReX，支持网格块分解和自适应网格加密。当前入门算例使用单层网格：

```text
amr.n_cell = 128
amr.max_grid_size = 64
amr.max_level = 0
```

含义：

- `amr.n_cell`：基础网格数；
- `amr.max_grid_size`：单个网格块最大尺寸，影响并行分解；
- `amr.max_level`：AMR 最大层级，`0` 表示不使用加密层。

建议先掌握单层网格，再学习 refined patch、moving window 和负载均衡。

## 12. 诊断与 openPMD

PIC 模拟需要诊断来判断物理和数值是否正确。常见诊断包括网格场、粒子数据、能量、谱和相空间分布。

当前示例写出 WarpX plotfile 和 openPMD 两种格式：

```text
diagnostics.diags_names = diag1 openpmd
diag1.intervals = 40
openpmd.intervals = 40
```

这会在第 0、40、80 步输出诊断。可视化脚本读取 plotfile 中的 `Ez` 和 `rho`：

```bash
./pic_base/envs/warpx/bin/python pic_base/scripts/plot_langmuir_1d.py
```

输出图片：

```text
pic_base/visualizations/langmuir_1d_fields.png
```

## 13. Langmuir 示例与理论的对应关系

当前 1D Langmuir 示例用电子-正电子等离子体的小振幅扰动展示 PIC 主流程。扰动频率尺度由等离子体频率给出：

$$
\omega_p = \sqrt{\frac{2 n_0 q_e^2}{\epsilon_0 m_e}},
\qquad
k_p = \frac{\omega_p}{c}.
$$

输入文件中对应写法是：

```text
my_constants.n0 = 2.e24
my_constants.wp = sqrt(2.*n0*q_e**2/(epsilon0*m_e))
my_constants.kp = wp/clight
my_constants.k = 2.*pi/20.e-6
```

理论概念和 WarpX 参数对应如下：

| 理论概念 | WarpX 输入参数示例 | 当前算例 |
|---|---|---|
| 计算区域 | `geometry.prob_lo`, `geometry.prob_hi` | `[-20e-6, 20e-6]` |
| 网格分辨率 | `amr.n_cell` | `128` |
| 时间长度 | `max_step` | `80` |
| CFL | `warpx.cfl` | `0.8` |
| 物种 | `particles.species_names` | `electrons positrons` |
| 粒子数 | `num_particles_per_cell_each_dim` | `2` |
| 密度 | `density` | `2e24 m^-3` |
| 沉积 | `algo.current_deposition` | `esirkepov` |
| 场插值 | `algo.field_gathering` | `energy-conserving` |
| 形函数 | `algo.particle_shape` | `1` |
| 诊断 | `diagnostics.diags_names` | `diag1 openpmd` |

## 14. 建议学习顺序

1. 阅读 `pic_base/examples/langmuir_1d/inputs`，理解网格、边界、物种和诊断。
2. 运行 `pic_base/scripts/run_langmuir_1d.sh`，确认输出结构。
3. 运行 `pic_base/scripts/plot_langmuir_1d.py`，观察 $E_z$ 与 $\rho$ 的演化。
4. 修改 `max_step`、`amr.n_cell`、每 cell 粒子数，比较运行时间和曲线变化。
5. 学习 2D/3D Langmuir 或 laser acceleration 示例。
6. 学习 Python/PICMI 输入方式，把纯文本输入转为 Python 脚本。
7. 深入 PSATD、moving window、boosted frame 和 AMR。

## 15. 本地文件索引

- 入门输入：`pic_base/examples/langmuir_1d/inputs`
- 运行脚本：`pic_base/scripts/run_langmuir_1d.sh`
- 输出检查：`pic_base/scripts/check_langmuir_outputs.py`
- 可视化脚本：`pic_base/scripts/plot_langmuir_1d.py`
- 可视化图片：`pic_base/visualizations/langmuir_1d_fields.png`
- 第一份简明笔记：`pic_base/docs/warpx_pic_notes.md`
- 本教程：`pic_base/docs/warpx_pic_theory_tutorial.md`

## 16. 官方文档入口

- WarpX 官方文档：https://warpx.readthedocs.io/en/latest/
- Theory 入口：https://warpx.readthedocs.io/en/latest/theory/
- 输入参数：https://warpx.readthedocs.io/en/latest/usage/parameters.html
- 示例入口：https://warpx.readthedocs.io/en/latest/usage/examples.html
