#!/usr/bin/env python3
from pathlib import Path
import sys

run_dir = Path(__file__).resolve().parents[1] / "runs" / "langmuir_1d"
required = [
    run_dir / "run.log",
    run_dir / "diags" / "openpmd",
]
missing = [str(path) for path in required if not path.exists()]
plotfiles = sorted((run_dir / "diags").glob("diag1*")) if (run_dir / "diags").exists() else []

if missing or not plotfiles:
    print("Missing expected outputs:")
    for item in missing:
        print(f"- {item}")
    if not plotfiles:
        print(f"- no plotfiles matching {run_dir / 'diags' / 'diag1*'}")
    sys.exit(1)

log_text = (run_dir / "run.log").read_text(errors="replace")
completed = "STEP 80 ends" in log_text or "STEP 80" in log_text
print(f"Run directory: {run_dir}")
print(f"Plotfiles: {', '.join(path.name for path in plotfiles)}")
print(f"openPMD directory: {run_dir / 'diags' / 'openpmd'}")
print(f"Reached step 80: {completed}")
sys.exit(0 if completed else 2)
