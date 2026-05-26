#!/usr/bin/env python3
"""Plot a lightweight summary from a CUDA WarpX run.log."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

import matplotlib.pyplot as plt

STEP_END_RE = re.compile(r"STEP\s+(\d+)\s+ends\.")
TIMING_RE = re.compile(r"This step =\s+([0-9.eE+-]+)\s+s; Avg\. per step =\s+([0-9.eE+-]+)\s+s")
GPU_TOTAL_RE = re.compile(r"Total GPU global memory \(MB\):\s+(\d+)")
GPU_FREE_RE = re.compile(r"Free\s+GPU global memory \(MB\):\s+(\d+)")
ARENA_ALLOC_RE = re.compile(r"\[The\s+Arena\] max space allocated \(MB\):\s+(\d+)")
ARENA_USED_RE = re.compile(r"\[The\s+Arena\] max space used\s+\(MB\):\s+(\d+)")


def parse_log(log_path: Path) -> dict[str, object]:
    steps: list[int] = []
    step_times: list[float] = []
    avg_times: list[float] = []
    gpu_summary: dict[str, int] = {}

    current_step: int | None = None
    for line in log_path.read_text(errors="replace").splitlines():
        if match := STEP_END_RE.search(line):
            current_step = int(match.group(1))
        elif match := TIMING_RE.search(line):
            if current_step is not None:
                steps.append(current_step)
                step_times.append(float(match.group(1)))
                avg_times.append(float(match.group(2)))
                current_step = None
        elif match := GPU_TOTAL_RE.search(line):
            gpu_summary["Total GPU memory"] = int(match.group(1))
        elif match := GPU_FREE_RE.search(line):
            gpu_summary["Free GPU memory after run"] = int(match.group(1))
        elif match := ARENA_ALLOC_RE.search(line):
            gpu_summary["AMReX arena allocated"] = int(match.group(1))
        elif match := ARENA_USED_RE.search(line):
            gpu_summary["AMReX arena used"] = int(match.group(1))

    if not steps:
        raise SystemExit(f"No WarpX step timing lines found in {log_path}")
    return {
        "steps": steps,
        "step_times": step_times,
        "avg_times": avg_times,
        "gpu_summary": gpu_summary,
    }


def plot_summary(data: dict[str, object], output_path: Path) -> None:
    steps = data["steps"]
    step_times = data["step_times"]
    avg_times = data["avg_times"]
    gpu_summary = data["gpu_summary"]

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5), constrained_layout=True)

    axes[0].plot(steps, step_times, marker="o", linewidth=1.4, label="per-step time")
    axes[0].plot(steps, avg_times, linewidth=2.0, label="running average")
    axes[0].set_xlabel("WarpX step")
    axes[0].set_ylabel("Time [s]")
    axes[0].set_title("CUDA WarpX 2D Langmuir step timing")
    axes[0].grid(alpha=0.3)
    axes[0].legend()

    labels = list(gpu_summary.keys())
    values = [gpu_summary[label] for label in labels]
    axes[1].barh(labels, values, color=["#4c78a8", "#72b7b2", "#f58518", "#54a24b"][: len(labels)])
    axes[1].set_xlabel("Memory [MB]")
    axes[1].set_title("GPU memory summary from AMReX")
    axes[1].grid(axis="x", alpha=0.3)
    for index, value in enumerate(values):
        axes[1].text(value, index, f" {value}", va="center")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=180)
    plt.close(fig)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", type=Path, default=Path("warpx_cuda_build/runs/gpu_langmuir_2d/run.log"))
    parser.add_argument("--output", type=Path, default=Path("warpx_cuda_build/visualizations/cuda_langmuir_run_summary.png"))
    args = parser.parse_args()
    plot_summary(parse_log(args.log), args.output)
    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
