# awk-telegram-bot
A simple telegram bot written in pure GNU Awk

# Setup
You'll need a [telegram bot api server](https://github.com/tdlib/telegram-bot-api) as api.telegram.org requires https, which is probably impossible to implement in AWK.
After setting up the server, replace *TG_SERVER*, *TG_PORT* and *TG_TOKEN* values with your own ones.

# Run
```bash
awk -f main.awk
```
