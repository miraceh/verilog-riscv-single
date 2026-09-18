#!/usr/bin/env python3

import argparse
import re
import subprocess
import sys
from pathlib import Path


def run_command(command, log_file=None):
    result = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    if log_file:
        log_file.write_text(result.stdout, encoding="utf-8")

    return result.returncode, result.stdout


def simulation_passed(return_code, output):
    if return_code != 0:
        return False

    if re.search(r"UVM_FATAL\s*:\s*[1-9]\d*", output):
        return False

    if re.search(r"UVM_ERROR\s*:\s*[1-9]\d*", output):
        return False

    if re.search(r"Failed=[1-9]\d*", output):
        return False

    return True


def main():
    parser = argparse.ArgumentParser(
        description="Run a multi-seed UVM regression and merge coverage."
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=10,
        help="Number of simulation runs, default: 10",
    )
    parser.add_argument(
        "--base-seed",
        type=int,
        default=1000,
        help="First simulation seed, default: 1000",
    )
    args = parser.parse_args()

    output_dir = Path("regression")
    output_dir.mkdir(exist_ok=True)

    print("Compiling design...")

    return_code, _ = run_command(
        ["make", "compile"],
        output_dir / "compile.log",
    )

    if return_code != 0:
        print(f"Compilation failed, log={output_dir}/compile.log")
        return 1

    passed_ucdbs = []
    passed = 0

    for index in range(args.runs):
        seed = args.base_seed + index
        ucdb = output_dir / f"coverage_{seed}.ucdb"
        log = output_dir / f"simulation_{seed}.log"

        command = [
            "make",
            "run",
            f"SEED={seed}",
            f"UCDB={ucdb}",
        ]

        print(f"[RUN ] seed={seed}")

        return_code, output = run_command(command, log)

        if simulation_passed(return_code, output):
            print(f"[PASS] seed={seed}")
            passed += 1
            passed_ucdbs.append(str(ucdb))
        else:
            print(f"[FAIL] seed={seed}, log={log}")

    print(f"\nRegression result: {passed}/{args.runs} passed")

    if not passed_ucdbs:
        print("No passing UCDB files to merge.")
        return 1

    merged_ucdb = output_dir / "merged.ucdb"

    merge_command = [
        "vcover",
        "merge",
        str(merged_ucdb),
        *passed_ucdbs,
    ]

    print("\nMerging coverage...")
    return_code, output = run_command(
        merge_command,
        output_dir / "coverage_merge.log",
    )

    if return_code != 0:
        print("Coverage merge failed.")
        return 1

    report_commands = [
        [
            "vcover",
            "report",
            "-details",
            "-cvg",
            "-output",
            str(output_dir / "functional_coverage.txt"),
            str(merged_ucdb),
        ],
        [
            "vcover",
            "report",
            "-details",
            "-output",
            str(output_dir / "full_coverage.txt"),
            str(merged_ucdb),
        ],
    ]

    for command in report_commands:
        return_code, _ = run_command(command)

        if return_code != 0:
            print("Coverage report generation failed.")
            return 1

    print("Coverage reports generated:")
    print(f"  {output_dir}/functional_coverage.txt")
    print(f"  {output_dir}/full_coverage.txt")

    return 0 if passed == args.runs else 1


if __name__ == "__main__":
    sys.exit(main())