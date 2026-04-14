#!/bin/sh
# Build static HTML render of the spec for spec.parleywallet.app.
#
# Requires pandoc (brew install pandoc). The site's Cloudflare Worker serves
# everything out of ./dist and redirects "/" and "/v1/protocol.html" to the
# canonical "/v1/protocol" path. The landing page at "/" is produced by the
# SEO track (M6) and is not created here.
#
# Guardrails honoured by this script:
#   - F-005: pandoc's auto-slug heading ids are preserved. The Lua filter
#     adds data-section="N.M" as an attribute only, never rewrites the id.
#   - F-006: the Lua filter asserts global heading id uniqueness and fails
#     the build on any duplicate.
#   - F-008: --fail-if-warnings is set so pandoc warnings fail CI.

set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="${ROOT}/dist"

# 1. Clean the output directory.
rm -rf "${DIST}"
mkdir -p "${DIST}/v1" "${DIST}/styles"

# 2. Copy the stylesheets.
cp "${ROOT}/build/styles/"*.css "${DIST}/styles/"

# 3. Render the spec.
pandoc "${ROOT}/v1/protocol.md" \
  --from markdown+pipe_tables+raw_html+yaml_metadata_block+auto_identifiers \
  --to html5 \
  --standalone \
  --template="${ROOT}/build/template.html" \
  --lua-filter="${ROOT}/build/lua/headings.lua" \
  --syntax-highlighting=tango \
  --toc \
  --toc-depth=4 \
  --section-divs \
  --fail-if-warnings \
  --metadata title="Parley Protocol Specification" \
  --output "${DIST}/v1/protocol.html"

echo "Built ${DIST}/v1/protocol.html"
