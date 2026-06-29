#!/usr/bin/env bash
# import-images.sh
# Pulls the chosen Envision photos from the capabilities repo, compresses them,
# and writes them into images/ with clean, deck-ready names.
#
# Run from the root of the clearview repo:  bash scripts/import-images.sh
# Requires ImageMagick (magick or convert) and curl.

set -euo pipefail

RAW="https://raw.githubusercontent.com/LauraRestum/envision-capabilites-services/main/images"
OUT="images"
mkdir -p "$OUT" .cache_src

# ImageMagick v7 uses `magick`, v6 uses `convert`
IM="$(command -v magick || command -v convert)"
if [ -z "$IM" ]; then echo "ImageMagick not found. Install it (brew install imagemagick)."; exit 1; fi

# fetch_resize <source-filename> <dest-filename> <max-dimension> <quality>
fetch_resize () {
  local src="$1" dest="$2" max="$3" q="$4"
  echo "  $dest  (<= ${max}px, q${q})"
  curl -fsSL "$RAW/$src" -o ".cache_src/$src"
  "$IM" ".cache_src/$src" -auto-orient -strip -resize "${max}x${max}>" \
        -interlace Plane -sampling-factor 4:2:0 -quality "$q" "$OUT/$dest"
}

echo "REQUIRED swaps:"
fetch_resize "envision-dallas-building-exterior.png"        "dallas-campus-exterior.jpg"  1920 82
fetch_resize "Envision-Day_01-0989.jpg"                     "contact-center-candid.jpg"   1920 82
fetch_resize "envision-employee-with-guide-dog-factory.png" "workforce-guide-dog.jpg"     1920 82
fetch_resize "DSC_6255.jpg"                                 "contact-center-agent.jpg"    1280 82

echo "OPTIONAL (print + Foundation slides):"
fetch_resize "binders-document-covers-showroom.png"        "storefront-showroom.jpg"     1280 82
fetch_resize "Envision-print-lableroll.png"                "print-fulfillment.jpg"       1280 82
fetch_resize "envision-white-cane-day-walk.jpg"            "foundation-wcdw.jpg"         1600 82

rm -rf .cache_src
echo "Done. New files in $OUT:"
ls -lh "$OUT" | grep -E 'dallas-campus|contact-center|workforce-guide|storefront|print-fulfillment|foundation-wcdw'
