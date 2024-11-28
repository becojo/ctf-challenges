#!/usr/bin/env python3

import sys
import os
import tempfile
import subprocess

GIT_DIR = os.environ["GIT_DIR"]

FILES_DENYLIST = {b".ci/run"}
ci_run = subprocess.check_output(["git", "show", "main:.ci/run"])

for line in sys.stdin.readlines():
    old_sha, new_sha, ref = line.split()

    if ref == "refs/heads/main":
        print(
            "Error: the main branch is protected and cannot be directly pushed. "
            "Please create a branch."
        )
        sys.exit(1)

    file_changed = subprocess.check_output(
        ["git", "diff", "--name-only", "refs/heads/main", new_sha],
    ).split()

    for changed in file_changed:
        if changed in FILES_DENYLIST:
            print(f"Error: updating `{changed.decode()}` is not allowed")
            sys.exit(1)

    with tempfile.TemporaryDirectory() as tmp:
        subprocess.run(
            ["bash", "-c", "git archive -- $0 | tar -m -x -C $1", new_sha, tmp],
        )

        os.chdir(tmp)

        ps = subprocess.run(
            [
                "python3",
            ],
            input=ci_run,
        )

        sys.exit(ps.returncode)
