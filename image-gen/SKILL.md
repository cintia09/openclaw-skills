---
name: image-gen
description: AI image generation via Pollinations.ai (free, no API key). Use when the user asks to generate, draw, or create an image/picture/illustration.
---

# AI Image Generation (多后端自动切换)

Generate images from text prompts — completely free, no API key, no registration.

**支持多后端自动降级**：Pollinations → AI Horde → Craiyon → Together.ai

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
| output_path | `/tmp/ai_image_<timestamp>.png` | Where to save |
| width | 1024 | Image width in pixels |
| height | 1024 | Image height in pixels |
| model | flux | Generation model (Pollinations only) |

## 后端优先级

| 后端 | 免费 | 速度 | 质量 | 需API Key |
|------|------|------|------|-----------|
| **Pollinations** | ✅ 完全免费 | ⚡ 快 | ⭐⭐⭐⭐ | ❌ |
| **AI Horde** | ✅ 完全免费 | 🐌 慢(排队) | ⭐⭐⭐ | ❌ (匿名可用) |
| **Craiyon** | ✅ 完全免费 | 🕐 中等 | ⭐⭐ | ❌ |
| **Together.ai** | ✅ 有免费额度 | ⚡ 快 | ⭐⭐⭐⭐ | ✅ TOGETHER_API_KEY |

脚本自动按优先级尝试，一个失败就试下一个。

## Available Models (Pollinations)

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
message send → channel=feishu, filePath=/tmp/image.png, message="description"

# Other channels
message send → channel=telegram/discord/etc, filePath=/tmp/image.png
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
- Rate limited per-backend (Pollinations generous but may temp-ban IPs; AI Horde uses kudos queue)
- curl needs `-k` flag (skip SSL verify) in some environments

## Troubleshooting

| Problem | Solution |
|---------|----------|
| SSL error | `-k` flag; or try next backend |
| Pollinations temp-banned | 等15-30分钟自动恢复; 脚本会自动尝试备选 |
| AI Horde 排队太久 | 匿名用户优先级低, 高峰可能等3-5分钟 |
| All backends fail | 手动访问 pollinations.ai / craiyon.com |
| Chinese prompt garbled | Script handles URL encoding via Python |
