# Setup Guide

## Finding Your Speaker's Device ID

### Method 1: Mi Home App

1. Open **Mi Home** (米家) app
2. Tap your speaker
3. Tap ⚙️ (top right) → scroll to bottom → find **Device ID**

### Method 2: Python Script

```python
import asyncio, aiohttp
from miservice import MiAccount, MiNAService, MiTokenStore

async def list_devices():
    async with aiohttp.ClientSession() as session:
        store = MiTokenStore('/tmp/mi_token.json')
        account = MiAccount(session, 'YOUR_ACCOUNT', 'YOUR_PASSWORD', store)
        await account.login('micoapi')
        mina = MiNAService(account)
        devices = await mina.device_list()
        for d in devices:
            print(f"Name: {d.get('name')}  DeviceID: {d.get('deviceID')}  DID: {d.get('did')}")

asyncio.run(list_devices())
```

## Testing Connectivity

```bash
python3 mi_speaker_tts.py "测试播报"
```

Expected output:
```
当前音量: 30
音量已调至: 50
OK: "测试播报"
等待 5s 播报完成...
音量已恢复: 30
```

## Token Management

- Token cached at `/tmp/mi_token.json`
- Auto-refreshed on each login call
- Login SID: `micoapi` (required for MiNA service)
- If token expires, script re-authenticates automatically
