#! /usr/bin/env python3

import os
import sys

import gi


def _require_root() -> None:
    if os.geteuid() != 0:
        print("Run as root: sudo goodix-reset", file=sys.stderr)
        raise SystemExit(1)


def main() -> None:
    _require_root()

    gi.require_version("FPrint", "2.0")
    from gi.repository import FPrint

    ctx = FPrint.Context()

    deleted = 0
    matched = False
    for dev in ctx.get_devices():
        driver = (dev.get_driver() or "").lower()
        if "goodix" not in driver:
            continue

        matched = True
        dev.open_sync()
        try:
            for p in dev.list_prints_sync():
                dev.delete_print_sync(p)
                deleted += 1
        finally:
            dev.close_sync()

    if not matched:
        print("No Goodix device found", file=sys.stderr)
        raise SystemExit(2)

    print(f"Goodix fingerprints cleared (deleted {deleted})")


if __name__ == "__main__":
    main()
