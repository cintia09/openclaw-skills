# OpenClaw Skills Collection

A curated collection of [OpenClaw](https://github.com/openclaw/openclaw) agent skills for daily productivity, automation, and specialized tasks.

## Skills

| Skill | Description | Language |
|-------|-------------|----------|
| [stock-trading-system](./stock-trading-system/) | A股量化交易系统 — 选股→监控→交易→三模型交叉复盘→调参 全闭环 | 🇨🇳 |
| [gaokao-exam-gen](./gaokao-exam-gen/) | 高考模拟试卷生成（LaTeX+TikZ带图版 / Markdown纯文本版） | 🇨🇳 |
| [xiaomi-speaker-tts](./xiaomi-speaker-tts/) | Xiaomi/Redmi smart speaker TTS via MiNA cloud API | 🌐 |
| [taobao-product-research](./taobao-product-research/) | 淘宝/天猫商品调研与选品 — 浏览器自动化采集评价 | 🇨🇳 |
| [xiaohongshu-post](./xiaohongshu-post/) | 小红书创作服务平台发帖（长文/图文） | 🇨🇳 |
| [task-dispatch](./task-dispatch/) | 子代理任务分配与模型选择策略 | 🇨🇳 |

## How to Use

1. Copy the skill folder into your OpenClaw workspace's `skills/` directory
2. The agent will auto-detect skills based on their `description` field
3. Each skill's `SKILL.md` contains full instructions — the agent reads it when the skill is triggered

## Structure

Each skill follows this structure:

```
skill-name/
├── SKILL.md              # Main skill file (required)
├── references/           # Supporting docs, API refs, specs
├── scripts/              # Helper scripts (if any)
└── assets/               # Templates, configs (if any)
```

## Contributing

Skills are designed for OpenClaw agents. To create a new skill:

1. Create a folder with a descriptive kebab-case name
2. Write a `SKILL.md` with YAML frontmatter (`name` + `description`)
3. Add references, scripts, and assets as needed
4. Submit a PR

## License

MIT
