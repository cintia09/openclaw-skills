#!/bin/bash
# Pollinations.ai Image Generator
# Free, no API key needed
# Usage: ./generate_image.sh "prompt" [output_path] [width] [height] [model]
#
# Models: flux (default), flux-realism, flux-anime, flux-3d, turbo, dall-e-3
# Example: ./generate_image.sh "a sunset over mountains" /tmp/sunset.jpg 1024 1024

set -e

PROMPT="${1:?Usage: $0 \"prompt\" [output_path] [width] [height] [model]}"
OUTPUT="${2:-/tmp/ai_image_$(date +%s).jpg}"
WIDTH="${3:-1024}"
HEIGHT="${4:-1024}"
MODEL="${5:-flux}"

# URL-encode the prompt
ENCODED_PROMPT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROMPT'))" 2>/dev/null || echo "$PROMPT" | sed 's/ /%20/g')

URL="https://image.pollinations.ai/prompt/${ENCODED_PROMPT}?width=${WIDTH}&height=${HEIGHT}&model=${MODEL}&nologo=true&seed=$RANDOM"

echo "🎨 Generating image..."
echo "   Prompt: $PROMPT"
echo "   Model: $MODEL"
echo "   Size: ${WIDTH}x${HEIGHT}"
echo "   Output: $OUTPUT"

HTTP_CODE=$(curl -s -k -o "$OUTPUT" -w "%{http_code}" -L "$URL" --max-time 120)

if [ "$HTTP_CODE" = "200" ]; then
    SIZE=$(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT" 2>/dev/null)
    if [ "$SIZE" -gt 1000 ]; then
        echo "✅ Done! ${SIZE} bytes saved to $OUTPUT"
    else
        echo "❌ File too small (${SIZE} bytes), generation may have failed"
        cat "$OUTPUT"
        exit 1
    fi
else
    echo "❌ HTTP error: $HTTP_CODE"
    cat "$OUTPUT" 2>/dev/null
    exit 1
fi
