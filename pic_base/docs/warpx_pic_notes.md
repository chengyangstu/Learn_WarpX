# WarpX PIC 学习笔记

> 本目录用于学习 WarpX 的 Particle-In-Cell（PIC）编程方法。环境已在本地 `pic_base/envs/warpx` 中配置完成，示例算例位于 `pic_base/examples/langmuir_1d/`。

## 参考资料

- WarpX 官方文档：https://warpx.readthedocs.io/en/latest/
- 用户安装文档：https://warpx.readthedocs.io/en/latest/install/users.html
- 理论与算法入口：https://warpx.readthedocs.io/en/latest/theory/
- 输入参数文档：https://warpx.readthedocs.io/en/latest/usage/parameters.html
- 示例入口：https://warpx.readthedocs.io/en/latest/usage/examples.html
- openPMD 输出标准：https://www.openpmd.org/

## 本地环境

本目录使用独立 micromamba，不修改系统 Python：

```bash
pic_base/tools/bin/micromamba --version
pic_base/tools/bin/micromamba run -p pic_base/envs/warpx warpx.1d --help
pic_base/tools/bin/micromamba run -p pic_base/envs/warpx python -c "import pywarpx; print(pywarpx.__file__)"
```

已安装的核心内容：

- `warpx`：WarpX 可执行程序，包含 `warpx.1d`、`warpx.2d`、`warpx.3d`、`warpx.rz` 等。
- `pywarpx`：WarpX Python 绑定，可用于 PICMI/Python 脚本方式配置算例。
- `openpmd-viewer`：读取 openPMD 诊断输出。
- `numpy`、`matplotlib`：后处理和画图基础库。

## 运行示例

从仓库根目录执行：

```bash
./pic_base/scripts/run_langmuir_1d.sh
./pic_base/envs/warpx/bin/python pic_base/scripts/check_langmuir_outputs.py
```

预期输出：

- `pic_base/runs/langmuir_1d/run.log`：运行日志。
- `pic_base/runs/langmuir_1d/warpx_used_inputs`：WarpX 实际使用的输入参数快照。
- `pic_base/runs/langmuir_1d/diags/diag1000000`、`diag1000040`、`diag1000080`：plotfile 诊断。
- `pic_base/runs/langmuir_1d/diags/openpmd/`：openPMD 格式诊断。

## PIC 方法核心思想

PIC 用“宏粒子 + 网格场”的混合表示来近似等离子体动力学：

1. **宏粒子表示分布函数**：真实等离子体包含巨大数量粒子，PIC 使用权重粒子代表许多真实粒子。
2. **电荷/电流沉积到网格**：粒子携带的电荷和电流按形函数分配到网格，得到 `rho`、`J`。
3. **网格上求解电磁场**：用 Maxwell 方程推进 `E`、`B`。
4. **场插值回粒子位置**：从网格场采样粒子所在位置的 `E`、`B`。
5. **推进粒子动量和位置**：用 Boris、Vay 等 pusher 解 Lorentz 力方程。
6. **循环推进时间步**：重复沉积、场推进、粒子推进和边界处理。

抽象循环如下：

```text
initialize particles and fields
for step in timesteps:
    deposit charge/current from particles to mesh
    solve Maxwell equations on mesh
    gather E/B from mesh to particle positions
    push particle momentum and position
    apply boundary conditions
    write diagnostics when requested
```

## WarpX 中的主要算法组件

### 网格与 AMR

WarpX 基于 AMReX，输入中常见参数：

- `geometry.dims`：维度，示例中为 `1`。
- `geometry.prob_lo` / `geometry.prob_hi`：物理区域边界。
- `amr.n_cell`：基础网格数。
- `amr.max_grid_size`：网格块最大尺寸，影响并行分解。
- `amr.max_level`：AMR 最大层级；入门示例固定为 `0`。

### 电磁场求解

入门示例使用默认 Yee FDTD 求解器：

- `warpx.cfl = 0.8` 控制时间步满足稳定性限制。
- `algo.current_deposition = esirkepov` 使用电荷守恒电流沉积。
- `algo.field_gathering = energy-conserving` 使用能量守恒场插值方式。
- `algo.particle_shape = 1` 使用一阶粒子形函数。

WarpX 也支持 PSATD 等谱求解器，适合相对论束流、激光等对数值色散更敏感的问题。

### 粒子物种

输入文件用 `particles.species_names` 声明物种。本示例定义：

- `electrons`：电荷 `-q_e`，质量 `m_e`。
- `positrons`：电荷 `q_e`，质量 `m_e`。

每个物种设置注入方式、密度、空间范围和初始动量分布。`NUniformPerCell` 表示每个网格单元均匀放置固定数量宏粒子。

### 诊断输出

本示例设置两个诊断：

- `diag1`：WarpX plotfile，方便 AMReX/原生工具读取。
- `openpmd`：openPMD 格式，更适合 Python 后处理和跨代码交换。

关键参数：

```text
diagnostics.diags_names = diag1 openpmd
diag1.intervals = 40
openpmd.intervals = 40
```

表示第 0、40、80 步会输出诊断。

## Langmuir 1D 示例物理含义

本示例是电子-正电子等离子体中的小振幅 Langmuir 振荡：

- 区域：`[-20 μm, 20 μm]` 的 1D 周期边界。
- 密度：电子和正电子均为 `n0 = 2e24 m^-3`。
- 扰动幅度：`epsilon = 0.01`，保持在线性小扰动范围。
- 初始动量：电子和正电子速度扰动方向相反，形成等离子体振荡。
- 目标：验证 PIC 主循环、粒子沉积、场求解、诊断输出都能工作。

输入中的派生量：

```text
wp = sqrt(2*n0*q_e^2/(epsilon0*m_e))
kp = wp/clight
k  = 2*pi/20e-6
```

其中 `wp` 是电子-正电子体系对应的等离子体频率尺度，`k` 是扰动波数。

## 输入文件阅读路线

建议按以下顺序阅读 `pic_base/examples/langmuir_1d/inputs`：

1. `max_step`、`amr.*`、`geometry.*`：先理解计算域和网格。
2. `boundary.*`：确认边界条件。
3. `algo.*`、`warpx.cfl`：理解数值算法选择。
4. `my_constants.*`：理解物理尺度。
5. `particles.*` 和各物种块：理解粒子初始化。
6. `diagnostics.*`：理解输出频率和格式。

## 下一步学习建议

- 将 `max_step` 改为 `160`，观察输出步数和运行时间变化。
- 将 `amr.n_cell` 改为 `256`，比较网格分辨率对诊断输出的影响。
- 将 `electrons.num_particles_per_cell_each_dim` 改为 `4`，观察粒子数和运行时间变化。
- 复制 `langmuir_1d` 为 `langmuir_2d`，改用官方 2D Langmuir 输入参数。
- 使用 `openpmd-viewer` 编写后处理脚本读取 `rho`、`Ez` 或粒子相空间。

## 本地可视化

当前已经生成 1D Langmuir 示例的电场与电荷密度图：

```bash
./pic_base/envs/warpx/bin/python pic_base/scripts/plot_langmuir_1d.py
```

输出文件：`pic_base/visualizations/langmuir_1d_fields.png`。

更系统的官网 PIC 理论整理见：`pic_base/docs/warpx_pic_theory_tutorial.md`。
