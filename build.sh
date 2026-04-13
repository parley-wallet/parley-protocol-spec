#!/bin/sh
# Build static HTML render of the spec for spec.parleywallet.app.
# Requires pandoc (brew install pandoc).

set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="${ROOT}/dist"

mkdir -p "${DIST}/v1"

pandoc "${ROOT}/v1/protocol.md" \
  --from markdown+pipe_tables+raw_html+yaml_metadata_block+auto_identifiers \
  --to html5 \
  --standalone \
  --toc \
  --toc-depth=3 \
  --metadata title="Parley Protocol Specification v1.0.0" \
  --css /style.css \
  --output "${DIST}/v1/protocol.html"

# Copy index that redirects to v1.
cat > "${DIST}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=/v1/protocol.html">
<title>Parley Protocol Specification</title>
</head>
<body>
<p>Redirecting to <a href="/v1/protocol.html">v1.0.0</a>.</p>
</body>
</html>
EOF

# Minimal stylesheet.
cat > "${DIST}/style.css" <<'EOF'
:root { color-scheme: light dark; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, sans-serif;
  max-width: 48rem;
  margin: 2rem auto;
  padding: 0 1rem;
  line-height: 1.55;
  font-size: 16px;
}
code, pre { font-family: "SF Mono", "JetBrains Mono", Menlo, monospace; font-size: 0.92em; }
pre { background: rgba(127,127,127,0.08); padding: 0.75rem 1rem; overflow-x: auto; border-radius: 6px; }
h1, h2, h3, h4 { line-height: 1.25; }
h1 { font-size: 1.9rem; }
h2 { font-size: 1.45rem; margin-top: 2.2rem; }
h3 { font-size: 1.18rem; margin-top: 1.6rem; }
table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
th, td { border: 1px solid rgba(127,127,127,0.4); padding: 0.4rem 0.7rem; text-align: left; }
nav#TOC { border: 1px solid rgba(127,127,127,0.3); padding: 0.5rem 1rem; border-radius: 6px; margin-bottom: 2rem; font-size: 0.95em; }
a { color: #0366d6; text-decoration: none; }
a:hover { text-decoration: underline; }
@media (prefers-color-scheme: dark) { body { background: #0d1117; color: #c9d1d9; } a { color: #58a6ff; } }
EOF

echo "Built ${DIST}/v1/protocol.html"
