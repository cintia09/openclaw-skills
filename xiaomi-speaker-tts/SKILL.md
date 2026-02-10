---
name: xiaomi-speaker-tts
description: Control Xiaomi/Redmi smart speakers via MiNA cloud API for TTS announcements, volume control, and playback management. Use when the user wants to make a Xiaomi speaker say something, set up voice reminders, control speaker volume, or automate announcements through Xiaomi smart speakers.
---

# Xiaomi Speaker TTS

Control Xiaomi/Redmi smart speakers remotely via MiNA cloud API. Supports TTS broadcasting, volume control, and playback management. Works over the internet — no LAN required.

## First-Time Setup

### 1. Install Dependencies

```bash
pip install miservice_fork aiohttp fake_useragent
```

### 2. Find Speaker Device ID

Copy `scripts/mi_speaker_tts.py` to your workspace (e.g. `xiaomi/mi_speaker_tts.py`). Then ask the user for their Xiaomi account credentials and run:

```python
python3 -c "
import asyncio, aiohttp
from miservice import MiAccount, MiNAService, MiTokenStore
async def ls():
    async with aiohttp.ClientSession() as s:
        a = MiAccount(s, 'ACCOUNT', 'PASSWORD', MiTokenStore('/tmp/mi_token.json'))
        await a.login('micoapi')
        for d in await MiNAService(a).device_list():
            print(f\"{d.get('name')}  deviceID={d.get('deviceID')}  DID={d.get('did')}\")
asyncio.run(ls())
"
```

### 3. Configure the Script

Edit the copied script's configuration section:

```python
MI_USER = 'user_xiaomi_account'
MI_PASS = 'user_password'
SPEAKER_DEVICE_ID = 'device_id_from_step_2'
DEFAULT_TTS_VOLUME = 50
```

### 4. Record in TOOLS.md

Save speaker details for future reference:

```markdown
## Xiaomi Speaker
- Device ID: xxx
- DID: xxx
- TTS command: python3 /path/to/mi_speaker_tts.py "text"
- Default volume: 50
```

### 5. Test

```bash
python3 /path/to/mi_speaker_tts.py "测试播报成功！"
```

Expected output:
```
当前音量: 30
音量已调至: 50
OK: "测试播报成功！"
等待 5s 播报完成...
音量已恢复: 30
```

## Usage

### Direct TTS

```bash
python3 /path/to/mi_speaker_tts.py "要说的话"
python3 /path/to/mi_speaker_tts.py "要说的话" --volume 70
```

The script automatically:
1. Reads current volume
2. Sets broadcast volume (default 50)
3. Speaks the text
4. Waits for speech to finish
5. Restores original volume

### OpenClaw Cron Integration

For scheduled announcements (reminders, alarms, etc.), create cron jobs:

```
cron add:
  sessionTarget: isolated
  delivery: { mode: "none" }   ← CRITICAL: must be "none"
  payload:
    kind: agentTurn
    message: |
      Execute this command:
      python3 /path/to/mi_speaker_tts.py "早上好！该起床了！"
      If it fails, retry once.
    timeoutSeconds: 90
```

**⚠️ IMPORTANT**: Always use `delivery: "none"` for TTS cron tasks. Using `delivery: "announce"` causes error→retry loops that result in repeated broadcasts.

### Volume Control Only

Use the MiNAService API directly:

```python
await mina.player_set_volume(DEVICE_ID, 60)
```

### Playback Control

```python
await mina.player_pause(DEVICE_ID)   # Pause
await mina.player_play(DEVICE_ID)    # Resume
await mina.player_stop(DEVICE_ID)    # Stop
```

## Supported Devices

Any speaker with XiaoAI (小爱同学):
- Xiaomi Speaker Pro / Mini
- XiaoAI Speaker (各代)
- Redmi XiaoAI Speaker
- Xiaomi Sound / Sound Pro
- Other devices with built-in XiaoAI

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Login failed | Check credentials; disable 2FA or use app password |
| No sound | Verify speaker online in Mi Home; increase `--volume` |
| Repeated broadcasts | Ensure cron `delivery` is `"none"`, not `"announce"` |
| Token expired | Script auto-refreshes; delete `/tmp/mi_token.json` to force |
| Volume not restoring | `player_get_status` response has nested JSON — script handles this |

## References

- `references/setup.md` — Detailed first-time setup walkthrough
- `references/api-reference.md` — Full MiNAService API (all methods + response formats)
