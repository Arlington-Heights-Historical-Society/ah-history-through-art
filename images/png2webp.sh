#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: png2webp <file.png> [quality]"
  exit 1
fi

INPUT="$1"
QUALITY="${2:-80}"

# Ensure file exists
if [ ! -f "$INPUT" ]; then
  echo "File not found: $INPUT"
  exit 1
fi

# Output file (same name, .webp)
OUTPUT="${INPUT%.*}.webp"

cwebp -q "$QUALITY" "$INPUT" -o "$OUTPUT"

echo "Created: $OUTPUT (quality=$QUALITY)"

