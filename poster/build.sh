#!/usr/bin/env bash
set -euo pipefail

poster_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
chrome_bin=${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}
registration_url=""

usage() {
  echo "Usage: $0 [--qr URL]" >&2
}

while (($#)); do
  case "$1" in
    --qr)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      registration_url=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

[[ -x "$chrome_bin" ]] || {
  echo "Chrome not found at: $chrome_bin" >&2
  echo "Set CHROME_BIN to another Chrome/Chromium executable." >&2
  exit 1
}

for required_command in pdfinfo pdftoppm qpdf uv; do
  command -v "$required_command" >/dev/null || {
    echo "Missing required command: $required_command" >&2
    exit 1
  }
done

if [[ -n "$registration_url" ]]; then
  command -v qrencode >/dev/null || {
    echo "Missing required command: qrencode" >&2
    exit 1
  }
  qrencode -t SVG -m 2 -o "$poster_dir/assets/qr-info.svg" "$registration_url"
fi

poster_url="file://$poster_dir/index.html"
check_dir=$(mktemp -d /tmp/sig-uva-poster-build.XXXXXX)
cleanup() {
  if command -v trash >/dev/null; then
    trash "$check_dir"
  else
    echo "Verification files left at: $check_dir" >&2
  fi
}
trap cleanup EXIT

if ! "$chrome_bin" \
  --headless=new \
  --disable-gpu \
  --hide-scrollbars \
  --window-size=1056,1632 \
  --force-device-scale-factor=1 \
  --screenshot="$poster_dir/poster.png" \
  "$poster_url" >"$check_dir/chrome-png.log" 2>&1; then
  cat "$check_dir/chrome-png.log" >&2
  exit 1
fi

if ! "$chrome_bin" \
  --headless=new \
  --disable-gpu \
  --no-pdf-header-footer \
  --print-to-pdf="$check_dir/poster-raw.pdf" \
  "$poster_url" >"$check_dir/chrome-pdf.log" 2>&1; then
  cat "$check_dir/chrome-pdf.log" >&2
  exit 1
fi

# Chrome embeds the build time. Normalize it so unchanged inputs produce an
# unchanged PDF and routine rebuilds do not dirty the repository.
qpdf --remove-info --remove-metadata --qdf --object-streams=disable \
  "$check_dir/poster-raw.pdf" "$check_dir/poster-qdf.pdf"
perl -0pi -e 's/D:\d{14}\+00\x2700\x27/D:20000101000000+00\x2700\x27/g; s{/ID \[<[^>]+><[^>]+>\]}{/ID [<00112233445566778899aabbccddeeff><00112233445566778899aabbccddeeff>]}g' \
  "$check_dir/poster-qdf.pdf"
# This PDF is unencrypted; a fixed document ID makes byte-for-byte rebuilds
# reproducible without weakening any encryption.
qpdf --static-id --object-streams=generate \
  "$check_dir/poster-qdf.pdf" "$poster_dir/poster.pdf"

page_size=$(pdfinfo "$poster_dir/poster.pdf" | awk -F: '/^Page size/ {gsub(/^[[:space:]]+/, "", $2); print $2}')
[[ "$page_size" == 792\ x\ 1224\ pts* ]] || {
  echo "Unexpected PDF page size: $page_size" >&2
  exit 1
}

pdftoppm -png -singlefile -r 96 \
  "$poster_dir/poster.pdf" \
  "$check_dir/poster-pdf" >/dev/null 2>&1

uv run --with opencv-python-headless python - \
  "$poster_dir/poster.png" \
  "$check_dir/poster-pdf.png" \
  "$registration_url" <<'PY'
import sys

import cv2

png_path, pdf_path, expected_url = sys.argv[1:]
for label, path in (("PNG", png_path), ("PDF", pdf_path)):
    image = cv2.imread(path)
    if image is None:
        raise SystemExit(f"Could not read {label}: {path}")
    if image.shape[1::-1] != (1056, 1632):
        raise SystemExit(f"Unexpected {label} dimensions: {image.shape[1]} x {image.shape[0]}")
    value, _, _ = cv2.QRCodeDetector().detectAndDecode(image)
    if not value:
        raise SystemExit(f"Could not decode QR from {label}")
    if expected_url and value != expected_url:
        raise SystemExit(f"{label} QR mismatch: expected {expected_url!r}, got {value!r}")
    print(f"{label}: 1056 x 1632; QR -> {value}")
PY

echo "PDF: 11 x 17 in ($page_size)"
echo "Built: $poster_dir/poster.png"
echo "Built: $poster_dir/poster.pdf"
