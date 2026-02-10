# MiNAService API Reference

## Available Methods

All methods are async. Require `DEVICE_ID` (the speaker's deviceID from device_list).

| Method | Parameters | Description |
|--------|-----------|-------------|
| `device_list()` | — | List all MiNA devices on account |
| `text_to_speech(deviceID, text)` | deviceID, text | Speak text on speaker |
| `player_get_status(deviceID)` | deviceID | Get playback status + volume |
| `player_set_volume(deviceID, volume)` | deviceID, volume (0-100) | Set volume |
| `player_play(deviceID)` | deviceID | Resume playback |
| `player_pause(deviceID)` | deviceID | Pause playback |
| `player_stop(deviceID)` | deviceID | Stop playback |
| `player_set_loop(deviceID, mode)` | deviceID, mode | Set loop mode |
| `play_by_url(deviceID, url)` | deviceID, url | Play audio from URL |
| `play_by_music_url(deviceID, url)` | deviceID, url | Play music from URL |
| `send_message(deviceID, text)` | deviceID, text | Send message to device |
| `get_latest_ask(deviceID)` | deviceID | Get latest voice query |

## Response Format

### text_to_speech
```json
{"code": 0, "message": "success..."}
```
`code == 0` means success.

### player_get_status
```json
{
  "code": 0,
  "data": {
    "code": 0,
    "info": "{ \"status\": 3, \"volume\": 50, \"loop_type\": 1 }"
  }
}
```
**Note**: `data.info` is a JSON string — must double-parse:
```python
import json
info = json.loads(status['data']['info'])
volume = info['volume']
```

## Authentication

```python
from miservice import MiAccount, MiNAService, MiTokenStore

store = MiTokenStore('/tmp/mi_token.json')
account = MiAccount(session, username, password, store)
await account.login('micoapi')  # SID must be 'micoapi'
mina = MiNAService(account)
```
