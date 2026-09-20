#!/usr/bin/env python3
"""Checks the two manifests parse and carry what Claude Code requires.

Valid JSON is not enough: a marketplace.json without `owner` parses fine and
breaks every install. `claude plugin validate .` is the full check, but it needs
Claude Code installed — this runs anywhere Python does, CI included.
"""
import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
errors = []


def load(relative_path):
    try:
        return json.loads((root / relative_path).read_text())
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{relative_path}: {exc}")
        return None


def require(obj, path, label):
    """Walks a dotted path and records anything missing or empty."""
    node = obj
    for key in path.split("."):
        if not isinstance(node, dict) or not node.get(key):
            errors.append(f"{label}: missing or empty `{path}`")
            return
        node = node[key]


plugin = load(".claude-plugin/plugin.json")
if plugin:
    for field in ("name", "version", "description"):
        require(plugin, field, "plugin.json")

marketplace = load(".claude-plugin/marketplace.json")
if marketplace:
    for field in ("name", "owner.name", "plugins"):
        require(marketplace, field, "marketplace.json")
    for index, entry in enumerate(marketplace.get("plugins") or []):
        for field in ("name", "source"):
            require(entry, field, f"marketplace.json plugins[{index}]")

if plugin and marketplace:
    listed = [entry.get("name") for entry in marketplace.get("plugins") or []]
    if plugin.get("name") not in listed:
        errors.append(
            f"marketplace.json does not list the plugin `{plugin.get('name')}` ({listed})"
        )

if errors:
    print("\n".join(f"✖ {e}" for e in errors))
    sys.exit(1)
print("✓ manifests valid")
