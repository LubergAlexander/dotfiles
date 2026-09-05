#!/usr/bin/env python3
"""Open copy-mode selection from stdin without evaluating selected shell syntax."""

import os
import re
import subprocess
import sys


def tmux_literal(argument):
    """Prevent tmux from treating a trailing semicolon as a command separator."""
    return argument[:-1] + r"\;" if argument.endswith(";") else argument


def main():
    action, pane, session = sys.argv[1:]
    if (
        action not in ("open", "edit")
        or not re.fullmatch(r"%[0-9]+", pane)
        or not re.fullmatch(r"\$[0-9]+", session)
    ):
        raise ValueError("expected open|edit, a tmux pane ID, and a tmux session ID")

    selection = sys.stdin.read().removesuffix("\n")
    if not selection or "\0" in selection:
        raise ValueError("select a nonempty path or URL without NUL characters")

    cwd = subprocess.check_output(
        ["tmux", "display-message", "-p", "-t", pane, "#{pane_current_path}"],
        text=True,
    ).removesuffix("\n")
    # Absolute filenames protect openers that do not understand '--' (xdg-open).
    # Spaces, quotes, '$()', and leading hyphens remain literal filename data.
    is_url = re.match(r"[A-Za-z][A-Za-z0-9+.-]*:", selection) is not None
    target = (
        selection
        if is_url and action == "open"
        else os.path.abspath(os.path.join(cwd, selection))
    )
    if action == "edit":
        # The binding captures its client session before starting this process. A pane
        # can belong to linked windows in multiple sessions, so rediscovering it here
        # could select whichever containing session was active most recently.
        command = [
            "tmux",
            "new-window",
            "-t",
            f"{session}:",
            "--",
            "nvim",
            "--",
            tmux_literal(target),
        ]
    elif sys.platform == "darwin":
        command = ["/usr/bin/open", "--", target]
    else:
        command = ["xdg-open", target]
    subprocess.run(command, cwd=cwd, check=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"tmux selection: {error}", file=sys.stderr)
        sys.exit(1)
