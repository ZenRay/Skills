---
description: 
---
# Shared Template Loader

> This module is referenced by `/paradigm-init`, `/paradigm-adopt`, `/paradigm-sync`.
> It is NOT a standalone slash command (prefixed with `_`).

---

## Constants

```python
REMOTE_URL = "https://github.com/ZenRay/QoderTemplate/archive/refs/heads/master.tar.gz"

# paradigm-init/adopt/sync each may override this list
NEEDED_PATHS_DEFAULT = [
    ".qoder/commands", ".qoder/agents", ".qoder/skills",
    ".qoderwork/hooks", "docs/standards", "AGENTS.md", "STATE.md",
    ".gitignore"
]
```

---

## load_template_in_memory()

Downloads the template tarball from GitHub and extracts needed files into a `{rel_path: content}` dict. No temp directories required.

```python
import urllib.request, tarfile, io

def load_template_in_memory(url=REMOTE_URL, needed_paths=NEEDED_PATHS_DEFAULT):
    """Load template files into memory dict from remote tarball."""
    files = {}
    with urllib.request.urlopen(url) as resp:
        with tarfile.open(fileobj=io.BytesIO(resp.read()), mode="r:gz") as tar:
            for member in tar.getmembers():
                if not member.isfile():
                    continue
                rel = "/".join(member.name.split("/")[1:])  # strip "QoderTemplate-master/"
                if any(rel.startswith(p) for p in needed_paths) and rel:
                    f = tar.extractfile(member)
                    if f:
                        files[rel] = f.read().decode("utf-8")
    return files
```

---

## Local Path Detection

Probes common local locations for a QoderTemplate copy. Returns the path if found, else `None`.

```python
import os

def detect_local_template():
    """Return local QoderTemplate path or None."""
    candidates = [
        os.path.expanduser("~/Documents/QoderTemplate"),
        os.path.join(os.path.dirname(os.getcwd()), "QoderTemplate"),
    ]
    return next(
        (p for p in candidates if os.path.exists(f"{p}/.qoder/setting.json")),
        None
    )
```

---

## Load Template (Local-First, Remote Fallback)

Unified entry point: uses local copy when available, falls back to remote tarball.

```python
def load_template(needed_paths=NEEDED_PATHS_DEFAULT):
    """
    Load template files into memory dict.
    Local copy preferred; remote tarball as fallback.
    Returns: dict { rel_path: content }
    """
    local_tpl = detect_local_template()

    if local_tpl:
        template_files = {}
        for needed in needed_paths:
            full = os.path.join(local_tpl, needed)
            if os.path.isfile(full):
                template_files[needed] = open(full, encoding="utf-8").read()
            elif os.path.isdir(full):
                for root, _, fnames in os.walk(full):
                    for fname in fnames:
                        abs_f = os.path.join(root, fname)
                        rel_f = os.path.relpath(abs_f, local_tpl)
                        template_files[rel_f] = open(abs_f, encoding="utf-8").read()
        print(f"  Using local template: {local_tpl}")
    else:
        print("  Local QoderTemplate not found, fetching from GitHub...")
        template_files = load_template_in_memory(needed_paths=needed_paths)
        print("  Remote template loaded (in-memory, no temp files)")

    return template_files
```

---

## Read Template Version

Extracts version from `STATE.md` content (pattern: `Vx.y`).

```python
import re

def read_template_version(template_files):
    """Extract version string (e.g., '1.0') from template STATE.md."""
    state_content = template_files.get("STATE.md", "")
    m = re.search(r'V(\d+\.\d+)', state_content)
    return m.group(1) if m else 'unknown'
```

---

## Write Template Files (for /paradigm-init)

Writes in-memory template files to target directory.

```python
def write_template_files(files, target_dir="."):
    """Write in-memory template files to target directory."""
    for rel_path, content in files.items():
        abs_path = os.path.join(target_dir, rel_path)
        os.makedirs(os.path.dirname(abs_path), exist_ok=True)
        with open(abs_path, "w", encoding="utf-8") as f:
            f.write(content)
```

---

*Referenced by: `paradigm-init.md`, `paradigm-adopt.md`, `paradigm-sync.md`*
