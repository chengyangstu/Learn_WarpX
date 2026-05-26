# subagent.md — relativistic_reconnection_maxwell_solvers

## 目录目的
本目录用于解析并缩小复现论文 “Particle-in-cell Simulations of Relativistic Magnetic Reconnection with Advanced Maxwell Solver Algorithms”。

## 维护规则
- 本文件记录本目录内部主要变化。
- 外层总览记录维护在 `../agent.md`。
- 更深层目录不强制维护 `subagent.md`。

## 当前结构
- `paper/`：论文 PDF、文本提取或元数据。
- `docs/`：论文解析与复现说明。
- `src/`：复现代码。
- `runs/`：运行输出数据。
- `figures/`：复现图像。

## 主要变更
- 2026-05-26：创建论文复现目录结构。
- 2026-05-26：下载论文 PDF `paper/2304.10566.pdf`，并用 `pdftotext` 提取 `paper/2304.10566.txt`。
- 2026-05-26：新增 `README.md`、`docs/paper_analysis.md`、`docs/reproduction_notes.md`。
- 2026-05-26：新增并运行 `src/reproduce_reconnection_solver_study.py`，生成 reduced reproduction 数据和图像。
