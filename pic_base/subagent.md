# subagent.md — pic_base

## 目录目的
`pic_base/` 用于学习 WarpX 的 Particle-In-Cell（PIC）编程方法，包含本地 WarpX 环境、入门算例、运行脚本、运行输出、可视化结果和理论笔记。

## 维护规则
- 本文件记录 `pic_base/` 内部发生的主要变化。
- 外层目录的总记录维护在 `../agent.md`。
- 更深层子目录不强制维护额外的 `subagent.md`。

## 当前结构
- `docs/`：理论与学习笔记，包含 `docs/warpx_pic_notes.md` 和 `docs/warpx_pic_theory_tutorial.md`。
- `examples/`：示例算例，当前包含 `examples/langmuir_1d/`。
- `scripts/`：运行、检查和可视化脚本。
- `runs/`：算例运行输出，可删除后重跑。
- `visualizations/`：后处理图片输出，当前包含 `visualizations/langmuir_1d_fields.png`。
- `envs/`：本地 micromamba/conda 环境，当前包含 `envs/warpx`。
- `tools/`：本地工具，当前包含 `tools/bin/micromamba`。
- `pkgs/`：micromamba 包缓存。

## 当前环境
- WarpX 环境：`envs/warpx`
- 运行命令：`tools/bin/micromamba run -p envs/warpx warpx.1d`
- 已验证 Python 绑定：`pywarpx`
- 已验证示例：`examples/langmuir_1d/inputs`
- 已验证可视化：`visualizations/langmuir_1d_fields.png`

## 常用命令
```bash
./pic_base/scripts/run_langmuir_1d.sh
./pic_base/envs/warpx/bin/python pic_base/scripts/check_langmuir_outputs.py
./pic_base/envs/warpx/bin/python pic_base/scripts/plot_langmuir_1d.py
pic_base/tools/bin/micromamba run -p pic_base/envs/warpx python -c "import pywarpx; print(pywarpx.__file__)"
```

## 主要变更
- 2026-05-26：创建 `pic_base/` 目录结构。
- 2026-05-26：安装 WarpX 26.04、`pywarpx`、`openpmd-viewer`、`numpy`、`matplotlib`。
- 2026-05-26：新增 1D Langmuir 波入门算例，输入文件为 `examples/langmuir_1d/inputs`。
- 2026-05-26：新增脚本 `scripts/run_langmuir_1d.sh` 和 `scripts/check_langmuir_outputs.py`。
- 2026-05-26：运行示例成功，输出包含 `runs/langmuir_1d/diags/diag1000000`、`diag1000040`、`diag1000080` 和 openPMD 输出。
- 2026-05-26：新增 `docs/warpx_pic_notes.md`，整理 PIC 主循环、WarpX 关键参数、Langmuir 示例物理含义和学习建议。
- 2026-05-26：将维护文档层级调整为外层 `agent.md` + 本目录 `subagent.md`。
- 2026-05-26：新增 `scripts/plot_langmuir_1d.py`，从 plotfile 读取 `Ez` 和 `rho` 并生成 `visualizations/langmuir_1d_fields.png`。
- 2026-05-26：新增 `docs/warpx_pic_theory_tutorial.md`，系统整理 WarpX 官网 PIC 理论教程。
- 2026-05-26：更新 `docs/warpx_pic_notes.md` 和 `examples/langmuir_1d/README.md`，加入可视化入口。
- 2026-05-26：重排 `docs/warpx_pic_theory_tutorial.md`，将 Vlasov-Maxwell、沉积、插值、Yee 推进、CFL、Langmuir 频率等内容改为数学公式环境。
