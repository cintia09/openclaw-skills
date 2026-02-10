#!/usr/bin/env python3
"""Xiaomi Smart Speaker TTS Script

Usage:
    python3 mi_speaker_tts.py "Text to speak"
    python3 mi_speaker_tts.py "Text to speak" --volume 60
    python3 mi_speaker_tts.py  # Default test message

Features:
    - Auto-adjusts volume before speaking, restores after
    - Estimates speech duration for proper volume restore timing
    - Supports --volume parameter for custom broadcast volume

Dependencies: pip install miservice_fork aiohttp fake_useragent
Token: /tmp/mi_token.json (auto-refreshed)
"""

import asyncio
import sys
import json
import aiohttp
from miservice import MiAccount, MiNAService, MiTokenStore

# ============ CONFIGURATION — EDIT THESE ============
MI_USER = 'YOUR_XIAOMI_ACCOUNT'
MI_PASS = 'YOUR_PASSWORD'
TOKEN_PATH = '/tmp/mi_token.json'
SPEAKER_DEVICE_ID = 'YOUR_DEVICE_ID'  # From device_list() or Mi Home app
DEFAULT_TTS_VOLUME = 50  # Volume during broadcast (0-100)
# =====================================================


async def tts(text: str, volume: int = DEFAULT_TTS_VOLUME):
    async with aiohttp.ClientSession() as session:
        store = MiTokenStore(TOKEN_PATH)
        account = MiAccount(session, MI_USER, MI_PASS, store)
        ok = await account.login('micoapi')
        if not ok:
            print('ERROR: Login failed')
            return False

        mina = MiNAService(account)

        # 1. Get current volume
        old_volume = None
        try:
            status = await mina.player_get_status(SPEAKER_DEVICE_ID)
            if isinstance(status, dict):
                data = status.get('data', {})
                if isinstance(data, dict):
                    info = data.get('info', '{}')
                    if isinstance(info, str):
                        info = json.loads(info)
                    old_volume = info.get('volume')
            print(f'Current volume: {old_volume}')
        except Exception as e:
            print(f'WARNING: Failed to get volume: {e}')

        # 2. Set broadcast volume
        try:
            await mina.player_set_volume(SPEAKER_DEVICE_ID, volume)
            print(f'Volume set to: {volume}')
        except Exception as e:
            print(f'WARNING: Failed to set volume: {e}')

        # 3. Speak
        result = await mina.text_to_speech(SPEAKER_DEVICE_ID, text)
        code = result.get('code', -1)
        if code == 0:
            print(f'OK: "{text}"')
        else:
            print(f'ERROR: {result}')
            return False

        # 4. Wait for speech to finish
        wait_seconds = max(len(text) / 4 + 3, 5)
        print(f'Waiting {wait_seconds:.0f}s for speech...')
        await asyncio.sleep(wait_seconds)

        # 5. Restore original volume
        if old_volume is not None and old_volume != volume:
            try:
                await mina.player_set_volume(SPEAKER_DEVICE_ID, old_volume)
                print(f'Volume restored: {old_volume}')
            except Exception as e:
                print(f'WARNING: Failed to restore volume: {e}')

        return True


if __name__ == '__main__':
    text = 'Hello! TTS test successful!'
    volume = DEFAULT_TTS_VOLUME

    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if args:
        text = args[0]

    if '--volume' in sys.argv:
        idx = sys.argv.index('--volume')
        if idx + 1 < len(sys.argv):
            volume = int(sys.argv[idx + 1])

    asyncio.run(tts(text, volume))
