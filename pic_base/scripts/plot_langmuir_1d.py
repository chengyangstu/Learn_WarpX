#!/usr/bin/env python3
from pathlib import Path
import re

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

base = Path(__file__).resolve().parents[1]
run_dir = base / "runs" / "langmuir_1d"
out_dir = base / "visualizations"
out_dir.mkdir(exist_ok=True)

plotfiles = sorted((run_dir / "diags").glob("diag1*"))
if not plotfiles:
    raise SystemExit(f"No plotfiles found under {run_dir / 'diags'}")


def read_field(plotfile: Path, field: str):
    header = plotfile / "Header"
    lines = header.read_text(errors="replace").splitlines()
    nfields = int(lines[1])
    fields = lines[2 : 2 + nfields]
    if field not in fields:
        raise ValueError(f"{field!r} not found in {plotfile}; available: {fields}")
    field_index = fields.index(field)

    prob_lo = float(lines[16].split()[0])
    prob_hi = float(lines[17].split()[0])

    level_dir = plotfile / "Level_0"
    cell_header = level_dir / "Cell_H"
    cell_lines = cell_header.read_text(errors="replace").splitlines()

    fab_specs = []
    for line in cell_lines:
        stripped = line.strip()
        if stripped.startswith("FabOnDisk:"):
            match = re.match(r"FabOnDisk:\s+(\S+)\s+(\d+)", stripped)
            if not match:
                raise ValueError(f"Unexpected FabOnDisk line: {stripped}")
            fab_specs.append((level_dir / match.group(1), int(match.group(2))))
    if not fab_specs:
        raise ValueError(f"Could not find FabOnDisk lines in {cell_header}")

    chunks = []
    total_cells = 0
    for data_file, offset in fab_specs:
        header_bytes = data_file.read_bytes()[offset : offset + 512]
        first_newline = header_bytes.find(b"\n")
        if first_newline < 0:
            raise ValueError(f"Could not parse FAB header in {data_file}")
        fab_header = header_bytes[:first_newline].decode(errors="replace")
        box_match = re.search(r"\(\(([-+]?\d+)\)\s+\(([-+]?\d+)\)\s+\(([-+]?\d+)\)\)\s+(\d+)\s*$", fab_header)
        if not box_match:
            raise ValueError(f"Could not parse FAB box from header: {fab_header}")
        lo = int(box_match.group(1))
        hi = int(box_match.group(2))
        ncomp = int(box_match.group(4))
        ncells = hi - lo + 1
        raw = np.fromfile(data_file, dtype=np.float64, offset=offset + first_newline + 1, count=ncells * ncomp)
        data = raw.reshape((ncells, ncomp))
        chunks.append((lo, data[:, field_index]))
        total_cells += ncells

    values = np.empty(total_cells)
    for lo, chunk in chunks:
        values[lo : lo + len(chunk)] = chunk

    dx = (prob_hi - prob_lo) / total_cells
    z = prob_lo + (np.arange(total_cells) + 0.5) * dx
    step_match = re.search(r"diag1(\d+)$", plotfile.name)
    step = int(step_match.group(1)) - 1_000_000 if step_match else -1
    return step, z, values

fig, axes = plt.subplots(2, 1, figsize=(9, 7), sharex=True)
for plotfile in plotfiles:
    step, z, ez = read_field(plotfile, "Ez")
    _, _, rho = read_field(plotfile, "rho")
    axes[0].plot(z * 1e6, ez, label=f"step {step}")
    axes[1].plot(z * 1e6, rho, label=f"step {step}")

axes[0].set_ylabel("Ez [SI]")
axes[0].set_title("WarpX 1D Langmuir Example: Ez and Charge Density")
axes[0].grid(True, alpha=0.3)
axes[0].legend()
axes[1].set_xlabel("z [μm]")
axes[1].set_ylabel("rho [C/m³]")
axes[1].grid(True, alpha=0.3)
axes[1].legend()
fig.tight_layout()

png = out_dir / "langmuir_1d_fields.png"
fig.savefig(png, dpi=180)
print(png)
