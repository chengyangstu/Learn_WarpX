# agent.md — PIC_learn

## 维护规则
- 本文件位于外层工作目录 `/home/cy191/PIC_learn/`，用于简要记录各一层子文件夹发生的变化。
- 每次新增、删除或明显修改外层目录的一层子文件夹后，更新本文件。
- 每个一层子文件夹内部只需要维护一个 `subagent.md`；更深层目录不强制维护。

## 文件夹变更记录

### `pic_base/`
- 2026-05-26：创建 WarpX/PIC 学习目录。
- 2026-05-26：下载本地 micromamba 到 `tools/`，并创建独立 WarpX 环境 `envs/warpx`。
- 2026-05-26：新增 1D Langmuir 波示例 `examples/langmuir_1d/`。
- 2026-05-26：新增运行与检查脚本 `scripts/run_langmuir_1d.sh`、`scripts/check_langmuir_outputs.py`。
- 2026-05-26：成功运行示例到第 80 步，输出位于 `runs/langmuir_1d/`。
- 2026-05-26：新增理论学习笔记 `docs/warpx_pic_notes.md`。
- 2026-05-26：按维护规则改为使用 `pic_base/subagent.md` 记录该子文件夹内部变化。
- 2026-05-26：为 `pic_base/` 新增可视化脚本与图片输出，并整理官网 PIC 理论教程到本地 Markdown。
- 2026-05-26：按官网教程风格重排 `pic_base/docs/warpx_pic_theory_tutorial.md`，物理方程改用 LaTeX 数学环境，命令和参数保留代码块。

### `relativistic_reconnection_maxwell_solvers/`
- 2026-05-26：创建论文 “Particle-in-cell Simulations of Relativistic Magnetic Reconnection with Advanced Maxwell Solver Algorithms” 的复现目录。
- 2026-05-26：下载并保存 arXiv 论文 PDF 与文本提取到 `paper/`。
- 2026-05-26：新增论文解析 `docs/paper_analysis.md` 和缩小版复现说明 `docs/reproduction_notes.md`。
- 2026-05-26：新增复现脚本 `src/reproduce_reconnection_solver_study.py`，已本地运行成功。
- 2026-05-26：生成复现数据 `runs/reduced_reproduction/` 和图像 `figures/`。

### GitHub 发布
- 2026-05-26：初始化 Git 仓库，添加 `.gitignore`，排除本地环境、包缓存、运行输出和论文原始下载文件；推送到 `https://github.com/chengyangstu/Learn_WarpX.git` 的 `main` 分支。

### `pic_base/`
- 2026-05-26：新增 GPU-ready 2D Langmuir 示例、后端检查脚本和运行说明；当前机器可见 NVIDIA GPU，但已确认现有 conda-forge WarpX 是 CPU/OpenMP 构建，本次运行是 CPU 功能验证。
