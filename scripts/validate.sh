#!/usr/bin/env bash
#
# scripts/validate.sh — standing consistency guard for the spec_driven_develop repo.
#
# Runs seven checks and prints one PASS/FAIL line per check. Exits non-zero if any
# check fails. Safe to run from any directory: the script cds to the repo root
# (the parent of this scripts/ directory) before doing any work.
#
# Dependencies (no new ones introduced):
#   - bash
#   - python3 (standard library only)
#   - node   (required for check (e); absence is a loud FAILURE, not a skip)
#   - git    (used to enumerate tracked files for check (a))
#
# Design choice (per task T1.4): path-reference extraction in check (a) is
# implemented in python3 stdlib rather than ripgrep (rg). This keeps the guard
# free of any rg dependency so it runs identically on machines without ripgrep.
#
# Checks:
#   (a) Reference existence  — backtick-quoted relative paths found in tracked
#        .md/.json/.js files must resolve to an existing file/dir. Candidates
#        containing template placeholders (<, >, {, }, *) or whitespace are
#        skipped. Resolution rules:
#          * paths starting with plugins/ or scripts/ resolve from the repo root;
#          * paths containing a references/, agents/, or templates/ segment that
#            name a file (basename has an extension) are tried against the repo
#            root, the referencing file's directory and each of its ancestors,
#            and every skill root (plugins/*\/skills/*/). The first base that
#            resolves wins. This matches how the skills and agent prompts write
#            skill-internal references (relative to the skill root).
#        docs/archives/ is excluded from scanning: those are frozen historical
#        snapshots whose internal references are intentionally not maintained.
#   (b) Manifest <-> filesystem parity — for plugins/spec-driven-develop/
#        .claude-plugin/plugin.json: every path in its agents (and commands, while
#        present) arrays exists on disk; no unlisted files live in agents/ (or
#        commands/); and every readPrompt("...") literal in opencode-plugin.js
#        resolves. An absent commands array is TOLERATED (it is slated for
#        deletion in a later phase, which must not require editing this script).
#   (c) Version parity — the version string must be identical across four sites:
#        SKILL.md frontmatter, .claude-plugin/plugin.json, .codex-plugin/
#        plugin.json, and the root .claude-plugin/marketplace.json (.plugins[0]).
#   (d) JSON validity — the four manifests above plus .agents/plugins/
#        marketplace.json must each parse as JSON.
#   (e) ESM syntax — `node --check --input-type=module` on opencode-plugin.js
#        (plain `node --check` parses as CommonJS and fails on `import`).
#   (f) py_compile — the three Python files must byte-compile.
#   (g) Exporter smoke test — run scripts/export-progress.py against the
#        known-good fixture in scripts/test-fixtures/progress/ and assert the
#        JSON structure (task name, one phase with two tasks, two parsed tasks
#        with non-empty priority/acceptance).
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

FAILURES=0

run_check() {
  local id="$1"; shift
  local desc="$1"; shift
  if "$@"; then
    echo "[PASS] ($id) $desc"
  else
    echo "[FAIL] ($id) $desc"
    FAILURES=$((FAILURES + 1))
  fi
}

# ---------------------------------------------------------------------------
# (a) Reference existence
# ---------------------------------------------------------------------------
check_a() {
  python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(".").resolve()
EXCLUDE_PREFIX = "docs/archives/"
SEGMENTS = ("references/", "agents/", "templates/")
SKIP_CHARS = set("<>{}*")
BACKTICK = re.compile(r"`([^`\n]+)`")

try:
    tracked = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
except Exception as exc:  # pragma: no cover - git should always be present here
    print(f"check (a): cannot enumerate tracked files: {exc}", file=sys.stderr)
    sys.exit(1)

files = [
    f for f in tracked
    if f.endswith((".md", ".json", ".js")) and not f.startswith(EXCLUDE_PREFIX)
]

SKILL_ROOTS = sorted(ROOT.glob("plugins/*/skills/*/"))


def classify(candidate):
    c = candidate.strip()
    if not c or any(ch in c for ch in SKIP_CHARS):
        return None
    if any(ch.isspace() for ch in c):
        return None
    if c.startswith(("plugins/", "scripts/")):
        return ("root", c)
    for seg in SEGMENTS:
        if c.startswith(seg) or ("/" + seg) in c:
            base = c.rstrip("/").rsplit("/", 1)[-1]
            if "." in base:  # names a file rather than a bare directory segment
                return ("rel", c)
            return None
    return None


def rel_bases(referencing_file):
    yield ROOT
    parent = (ROOT / referencing_file).parent
    while True:
        yield parent
        if parent == ROOT:
            break
        parent = parent.parent
    for sr in SKILL_ROOTS:
        yield sr


def resolves(kind, candidate, referencing_file):
    if kind == "root":
        return (ROOT / candidate).exists()
    return any((b / candidate).exists() for b in rel_bases(referencing_file))


missing = []
for f in files:
    try:
        text = (ROOT / f).read_text(encoding="utf-8")
    except OSError:
        continue  # tracked but unreadable/removed on disk; nothing to scan
    for m in BACKTICK.finditer(text):
        cl = classify(m.group(1))
        if not cl:
            continue
        kind, candidate = cl
        if not resolves(kind, candidate, f):
            missing.append((candidate, f))

if missing:
    for candidate, f in missing:
        print(f"check (a): broken reference `{candidate}` in {f}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
}

# ---------------------------------------------------------------------------
# (b) Manifest <-> filesystem parity
# ---------------------------------------------------------------------------
check_b() {
  python3 - <<'PY'
import json
import re
import sys
from pathlib import Path

PLUGIN = Path("plugins/spec-driven-develop")
MANIFEST = PLUGIN / ".claude-plugin" / "plugin.json"

errors = []
try:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
except Exception as exc:
    print(f"check (b): cannot parse {MANIFEST}: {exc}", file=sys.stderr)
    sys.exit(1)

# 1) Every path listed in agents/ (and commands/, while present) exists; and
# 2) no unlisted files live in the corresponding directory. An absent key is
#    tolerated so a future phase that drops `commands` needs no edit here.
for key in ("agents", "commands"):
    entries = manifest.get(key)
    if entries is None:
        continue
    listed_names = set()
    for entry in entries:
        listed_names.add(Path(entry).name)
        if not (PLUGIN / entry).exists():
            errors.append(f"listed {key} entry missing on disk: {entry}")
    directory = PLUGIN / key
    if directory.is_dir():
        for f in sorted(directory.iterdir()):
            if f.is_file() and f.name not in listed_names:
                errors.append(f"unlisted file in {key}/: {f.name}")

# 3) Every readPrompt("...") literal in opencode-plugin.js resolves.
js_path = PLUGIN / "opencode-plugin.js"
try:
    js = js_path.read_text(encoding="utf-8")
except OSError as exc:
    errors.append(f"cannot read {js_path}: {exc}")
else:
    for m in re.finditer(r"readPrompt\([\"']([^\"']+)[\"']\)", js):
        rel = m.group(1)
        if not (PLUGIN / rel).exists():
            errors.append(f"readPrompt target missing: {rel}")

if errors:
    for e in errors:
        print(f"check (b): {e}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
}

# ---------------------------------------------------------------------------
# (c) Version parity
# ---------------------------------------------------------------------------
check_c() {
  python3 - <<'PY'
import json
import re
import sys
from pathlib import Path

PLUGIN = Path("plugins/spec-driven-develop")


def skill_version():
    text = (PLUGIN / "skills" / "spec-driven-develop" / "SKILL.md").read_text(
        encoding="utf-8"
    )
    fm = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    block = fm.group(1) if fm else text
    m = re.search(r"^\s*version:\s*(.+?)\s*$", block, re.MULTILINE)
    return m.group(1) if m else None


def json_version(path, key_path):
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"check (c): cannot parse {path}: {exc}", file=sys.stderr)
        return None
    node = data
    for key in key_path:
        if not isinstance(node, (dict, list)):
            return None
        try:
            node = node[key]
        except (KeyError, IndexError, TypeError):
            return None
    return node


versions = {
    "SKILL.md frontmatter": skill_version(),
    "plugins/spec-driven-develop/.claude-plugin/plugin.json": json_version(
        PLUGIN / ".claude-plugin" / "plugin.json", ["version"]
    ),
    "plugins/spec-driven-develop/.codex-plugin/plugin.json": json_version(
        PLUGIN / ".codex-plugin" / "plugin.json", ["version"]
    ),
    ".claude-plugin/marketplace.json": json_version(
        ".claude-plugin/marketplace.json", ["plugins", 0, "version"]
    ),
}

distinct = set(versions.values())
if None in distinct or len(distinct) != 1:
    for site, value in versions.items():
        print(f"check (c):   {site}: {value}", file=sys.stderr)
    print("check (c): version mismatch across sites", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
}

# ---------------------------------------------------------------------------
# (d) JSON validity
# ---------------------------------------------------------------------------
check_d() {
  python3 - <<'PY'
import json
import sys
from pathlib import Path

MANIFESTS = [
    "plugins/spec-driven-develop/.claude-plugin/plugin.json",
    "plugins/spec-driven-develop/.codex-plugin/plugin.json",
    ".claude-plugin/marketplace.json",
    ".agents/plugins/marketplace.json",
]

bad = []
for f in MANIFESTS:
    try:
        json.loads(Path(f).read_text(encoding="utf-8"))
    except Exception as exc:
        bad.append(f"{f}: {exc}")

if bad:
    for b in bad:
        print(f"check (d): invalid JSON {b}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
}

# ---------------------------------------------------------------------------
# (e) ESM syntax of the OpenCode plugin entrypoint
# ---------------------------------------------------------------------------
check_e() {
  if ! command -v node >/dev/null 2>&1; then
    echo "check (e): node not found; cannot run ESM syntax check" >&2
    return 1
  fi
  node --check --input-type=module < plugins/spec-driven-develop/opencode-plugin.js
}

# ---------------------------------------------------------------------------
# (f) py_compile the Python sources
# ---------------------------------------------------------------------------
check_f() {
  python3 -m py_compile \
    scripts/export-progress.py \
    scripts/review-context.py \
    plugins/spec-driven-develop/skills/review-spd/scripts/review-context.py
}

# ---------------------------------------------------------------------------
# (g) Exporter smoke test against the known-good fixture
# ---------------------------------------------------------------------------
check_g() {
  python3 - <<'PY'
import json
import subprocess
import sys

result = subprocess.run(
    [sys.executable, "scripts/export-progress.py", "scripts/test-fixtures/progress/"],
    capture_output=True,
    text=True,
)
if result.returncode != 0:
    print(f"check (g): exporter exited {result.returncode}: {result.stderr.strip()}",
          file=sys.stderr)
    sys.exit(1)

try:
    data = json.loads(result.stdout)
except json.JSONDecodeError as exc:
    print(f"check (g): exporter output is not valid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

errors = []
if data.get("task") != "Exporter Smoke Fixture":
    errors.append(f"unexpected task name: {data.get('task')!r}")

phases = data.get("phases", [])
if len(phases) != 1:
    errors.append(f"expected 1 phase, got {len(phases)}")
else:
    phase = phases[0]
    if phase.get("total_tasks") != 2:
        errors.append(f"expected total_tasks == 2, got {phase.get('total_tasks')}")
    tasks = phase.get("tasks", [])
    if len(tasks) != 2:
        errors.append(f"expected 2 parsed tasks, got {len(tasks)}")
    for t in tasks:
        if not t.get("priority"):
            errors.append(f"task {t.get('id')} has empty priority")
        if not t.get("acceptance"):
            errors.append(f"task {t.get('id')} has empty acceptance")

if errors:
    for e in errors:
        print(f"check (g): {e}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
}

# ---------------------------------------------------------------------------
# Run all checks
# ---------------------------------------------------------------------------
run_check a "reference existence" check_a
run_check b "manifest <-> filesystem parity" check_b
run_check c "version parity" check_c
run_check d "JSON validity of manifests" check_d
run_check e "ESM syntax of opencode-plugin.js" check_e
run_check f "py_compile Python sources" check_f
run_check g "exporter smoke test (fixture)" check_g

echo
if [ "$FAILURES" -gt 0 ]; then
  echo "validate.sh: $FAILURES check(s) FAILED" >&2
  exit 1
fi
echo "validate.sh: all 7 checks passed"
exit 0
