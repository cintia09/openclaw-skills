---
name: image-gen
description: AI image generation via Pollinations.ai (free, no API key). Use when the user asks to generate, draw, or create an image/picture/illustration.
---

# AI Image Generation

Generate images from text prompts using Pollinations.ai — completely free, no API key, no registration.

## Quick Start

```bash
./scripts/generate_image.sh "a sunset over mountains" /tmp/sunset.jpg
```

## Usage

```bash
./scripts/generate_image.sh "prompt" [output_path] [width] [height] [model]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| prompt | (required) | Text description of the image |
| output_path | `/tmp/ai_image_<timestamp>.jpg` | Where to save |
| width | 1024 | Image width in pixels |
| height | 1024 | Image height in pixels |
| model | flux | Generation model |

## Available Models

| Model | Style | Best For |
|-------|-------|----------|
| `flux` | General purpose | Default, good all-around |
| `flux-realism` | Photorealistic | Portraits, landscapes, product shots |
| `flux-anime` | Anime/manga | Anime characters, illustrations |
| `flux-3d` | 3D rendered | 3D objects, scenes |
| `turbo` | Fast generation | Quick drafts, iteration |
| `dall-e-3` | DALL-E style | Creative, artistic |

## Integration with Messaging

After generating, send the image to the user via their messaging channel:

```
# Feishu
message send → channel=feishu, filePath=/tmp/image.jpg, message="description"

# Other channels
message send → channel=telegram/discord/etc, filePath=/tmp/image.jpg
```

## Prompt Tips

- **Supports both Chinese and English** prompts
- Be specific: "a golden retriever puppy playing in autumn leaves, warm sunlight" > "a dog"
- Mention style: "watercolor painting of...", "photorealistic...", "anime style..."
- Mention lighting: "soft warm lighting", "dramatic shadows", "golden hour"
- Mention composition: "close-up", "wide angle", "bird's eye view"

## Limitations

- No image editing (inpainting, outpainting) — generation only
- No consistent characters across images
- Rate limited by Pollinations (generous but not infinite)
- curl needs `-k` flag (skip SSL verify) in some environments

## Troubleshooting

| Problem | Solution |
|---------|----------|
| SSL error (exit code 35) | Ensure `-k` flag in curl |
| Timeout | Increase `--max-time`, default 120s |
| Small/corrupt file | Retry, server may be overloaded |
| Chinese prompt garbled | Script handles URL encoding via Python |
