#!/usr/bin/env bash
set -euo pipefail

# graphify-setup — detect Claude Code projects, install graphify,
# wire it into Claude Code, and prompt to build the graph.
#
# Usage: ./setup-graphify.sh [project-root]
#   project-root defaults to the current directory

ROOT="${1:-$(pwd)}"
ROOT="$(cd "$ROOT" && pwd)"

echo "==> Checking for Claude Code project at $ROOT"

# ── 1. Must have CLAUDE.md ──────────────────────────────────────────────
if [[ ! -f "$ROOT/CLAUDE.md" ]]; then
    echo "✗  No CLAUDE.md found — this project isn't using Claude Code."
    echo "   Run 'claude init' first, then re-run this script."
    exit 1
fi
echo "✓  CLAUDE.md found"

# ── 2. Detect or install Python + graphify ──────────────────────────────
PYTHON=""
GRAPHIFY_BIN="$(command -v graphify 2>/dev/null || true)"

# 2a. Check uv tool installs (most reliable on modern Mac/Linux)
if command -v uv >/dev/null 2>&1; then
    _UV_PY="$(uv tool run graphifyy python -c "import sys; print(sys.executable)" 2>/dev/null || true)"
    if [[ -n "$_UV_PY" ]]; then
        PYTHON="$_UV_PY"
    fi
fi

# 2b. Read shebang from graphify binary (pipx / direct pip installs)
if [[ -z "$PYTHON" && -n "$GRAPHIFY_BIN" ]]; then
    _SHEBANG="$(head -1 "$GRAPHIFY_BIN" | sed 's/^#!//')"
    case "$_SHEBANG" in
        *[!a-zA-Z0-9/_.-]*) ;;  # suspicious shebang, skip
        *) "$_SHEBANG" -c "import graphify" 2>/dev/null && PYTHON="$_SHEBANG" ;;
    esac
fi

# 2c. Fall back to system python3
if [[ -z "$PYTHON" ]]; then
    PYTHON="python3"
fi

if ! "$PYTHON" -c "import graphify" 2>/dev/null; then
    echo "--> graphify not found, installing..."
    if command -v uv >/dev/null 2>&1; then
        uv tool install --upgrade graphifyy -q 2>&1 | tail -3
        _UV_PY="$(uv tool run graphifyy python -c "import sys; print(sys.executable)" 2>/dev/null || true)"
        if [[ -n "$_UV_PY" ]]; then
            PYTHON="$_UV_PY"
        fi
    else
        echo "    uv not found — falling back to pip"
        "$PYTHON" -m pip install graphifyy -q 2>/dev/null ||
            "$PYTHON" -m pip install graphifyy -q --break-system-packages 2>&1 | tail -3
    fi
    echo "✓  graphify installed"
else
    echo "✓  graphify already installed"
fi

# ── 3. Write interpreter path for future invocations ────────────────────
mkdir -p "$ROOT/graphify-out"
"$PYTHON" -c "import sys; open('$ROOT/graphify-out/.graphify_python', 'w').write(sys.executable)"

# ── 4. Write scan root ──────────────────────────────────────────────────
echo "$ROOT" > "$ROOT/graphify-out/.graphify_root"

# ── 5. Verify graphify works ────────────────────────────────────────────
GRAPHIFY_VERSION="$("$PYTHON" -c "import graphify; print(getattr(graphify, '__version__', 'ok'))" 2>/dev/null || echo "ok")"
echo "✓  graphify $GRAPHIFY_VERSION ready"

# ── 6. Quick corpus scan ────────────────────────────────────────────────
cd "$ROOT"
FILE_COUNT="$("$PYTHON" -c "
from graphify.detect import detect
from pathlib import Path
r = detect(Path('.'))
non_code = sum(len(r['files'].get(k,[])) for k in ['document','paper','image'])
print(non_code)
" 2>/dev/null || echo "?")"

# ── 7. Wire graphify into Claude Code ───────────────────────────────────
echo ""
echo "==> Wiring graphify into Claude Code..."
graphify claude install 2>&1 || echo "⚠  graphify claude install failed — you may need to run it manually"
echo "✓  Claude Code integration complete"

# ── 8. Summary ──────────────────────────────────────────────────────────
echo ""
echo "══ Setup complete ══"
echo "   project:         $ROOT"
echo "   python:          $PYTHON"
echo "   graphify:        $GRAPHIFY_VERSION"
echo "   semantic files:  ~${FILE_COUNT}"
echo ""
echo "   Next: run /graphify in Claude Code to build the knowledge graph."
echo ""
echo "   Why inside Claude Code? The skill dispatches subagents in parallel"
echo "   with live progress per chunk. The CLI (graphify extract) runs"
echo "   silently during semantic extraction — no progress until it finishes."
echo ""
echo "   After the graph is built, Claude Code will use it automatically."
