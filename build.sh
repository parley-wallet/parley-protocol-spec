#!/bin/sh
# Build static HTML render of the spec for spec.parleywallet.app.
# Requires pandoc (brew install pandoc).

set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="${ROOT}/dist"
STATIC="${ROOT}/static"
BUILDDIR="${ROOT}/build"

mkdir -p "${DIST}/v1" "${DIST}/assets" "${DIST}/styles"

# --- 1. Render the spec --------------------------------------------------
# If Sarah's pandoc template exists, use it. Otherwise fall back to pandoc default.
# Use positional params to safely pass args with spaces (no POSIX arrays).
set -- \
  --from markdown+pipe_tables+raw_html+yaml_metadata_block+auto_identifiers \
  --to html5 \
  --standalone \
  --toc \
  --toc-depth=3 \
  --metadata "title=Parley Protocol Specification v1.0.0" \
  --output "${DIST}/v1/protocol.html"

if [ -f "${BUILDDIR}/template.html" ]; then
  set -- "$@" --template="${BUILDDIR}/template.html"
else
  # Legacy fallback: pandoc's default template + /style.css.
  set -- "$@" --css /style.css
fi

if [ -d "${BUILDDIR}/lua" ]; then
  for lf in "${BUILDDIR}/lua"/*.lua; do
    [ -f "${lf}" ] && set -- "$@" --lua-filter="${lf}"
  done
fi

pandoc "${ROOT}/v1/protocol.md" "$@"

# --- 2. Copy static assets into dist/ ------------------------------------
if [ -d "${STATIC}" ]; then
  # index.html, sitemap.xml, robots.txt, assets/, etc.
  cp -R "${STATIC}/." "${DIST}/"
fi

# --- 2b. Rasterise SVG sources into the PNG variants the SEO head expects.
# Uses rsvg-convert if available (brew install librsvg), otherwise ImageMagick
# (brew install imagemagick). If neither is installed, the PNGs are skipped
# and Kate needs to supply final raster images.
ASSETS_DIR="${DIST}/assets"
RASTERISE=""
if command -v rsvg-convert >/dev/null 2>&1; then
  RASTERISE="rsvg-convert"
elif command -v magick >/dev/null 2>&1; then
  RASTERISE="magick"
elif command -v convert >/dev/null 2>&1; then
  RASTERISE="convert"
fi

if [ -n "${RASTERISE}" ] && [ -f "${ASSETS_DIR}/favicon.svg" ]; then
  case "${RASTERISE}" in
    rsvg-convert)
      rsvg-convert -w 32 -h 32 "${ASSETS_DIR}/favicon.svg" -o "${ASSETS_DIR}/favicon-32.png"
      rsvg-convert -w 180 -h 180 "${ASSETS_DIR}/favicon.svg" -o "${ASSETS_DIR}/apple-touch-icon.png"
      ;;
    magick|convert)
      "${RASTERISE}" -background none -resize 32x32 "${ASSETS_DIR}/favicon.svg" "${ASSETS_DIR}/favicon-32.png"
      "${RASTERISE}" -background none -resize 180x180 "${ASSETS_DIR}/favicon.svg" "${ASSETS_DIR}/apple-touch-icon.png"
      ;;
  esac
fi

if [ -n "${RASTERISE}" ] && [ -f "${ASSETS_DIR}/og-spec-v1.svg" ]; then
  case "${RASTERISE}" in
    rsvg-convert)
      rsvg-convert -w 1200 -h 630 "${ASSETS_DIR}/og-spec-v1.svg" -o "${ASSETS_DIR}/og-spec-v1.png"
      ;;
    magick|convert)
      "${RASTERISE}" -background "#0B1220" -resize 1200x630 "${ASSETS_DIR}/og-spec-v1.svg" "${ASSETS_DIR}/og-spec-v1.png"
      ;;
  esac
fi

if [ -z "${RASTERISE}" ]; then
  echo "warn: no SVG rasteriser found (install librsvg or imagemagick)." >&2
  echo "warn: favicon-32.png, apple-touch-icon.png, og-spec-v1.png not generated." >&2
fi

# --- 3. Splice head-seo.html into the protocol page ----------------------
# Sarah's template leaves a `<!-- SEO_HEAD_INJECT -->` marker at the end of
# <head>. We replace that marker with the real tags.
HEAD_SEO="${BUILDDIR}/head-seo.html"
PROTOCOL_HTML="${DIST}/v1/protocol.html"

if [ -f "${HEAD_SEO}" ] && [ -f "${PROTOCOL_HTML}" ]; then
  # Resolve {{GIT_COMMIT_DATE}} placeholder (article:modified_time etc).
  # Use committer date of HEAD; fall back to today if not a git repo.
  if GIT_DATE="$(git -C "${ROOT}" log -1 --format=%cI 2>/dev/null)" && [ -n "${GIT_DATE}" ]; then
    :
  else
    GIT_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  fi

  TMPHEAD="$(mktemp)"
  # Substitute the placeholder first, then splice.
  sed "s|{{GIT_COMMIT_DATE}}|${GIT_DATE}|g" "${HEAD_SEO}" > "${TMPHEAD}"

  TMPOUT="$(mktemp)"
  if grep -q "<!-- SEO_HEAD_INJECT -->" "${PROTOCOL_HTML}"; then
    # Replace Sarah's marker with the SEO tags (BSD and GNU awk compatible).
    awk -v inc="${TMPHEAD}" '
      /<!-- SEO_HEAD_INJECT -->/ {
        while ((getline line < inc) > 0) print line
        close(inc)
        next
      }
      { print }
    ' "${PROTOCOL_HTML}" > "${TMPOUT}"
    mv "${TMPOUT}" "${PROTOCOL_HTML}"
  else
    # Fallback (no template.html yet): insert before </head>.
    awk -v inc="${TMPHEAD}" '
      /<\/head>/ && !done {
        while ((getline line < inc) > 0) print line
        close(inc)
        done = 1
      }
      { print }
    ' "${PROTOCOL_HTML}" > "${TMPOUT}"
    mv "${TMPOUT}" "${PROTOCOL_HTML}"
  fi
  rm -f "${TMPHEAD}"
fi

# --- 4. Legacy minimal stylesheet ----------------------------------------
# Only emit /style.css when Sarah's main.css is not present (fallback path).
if [ ! -f "${DIST}/styles/main.css" ]; then
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
fi

echo "Built ${DIST}/v1/protocol.html"
echo "Built ${DIST}/index.html"
echo "Copied sitemap.xml, robots.txt, assets/"
