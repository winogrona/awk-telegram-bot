#!/bin/awk -f
@include "config.awk"
@include "telegram.awk"

BEGIN {
  seeded = 0
  while (1) {
    resp = poll()
    
    if (resp == "error") {
      print("Failed to poll new updates")
      exit(1)
    }
    else if (resp == "empty") {
      print("No new updates")
      continue
    }

    if (seeded == 0) {
      srand(TG_RT_OFFSET)
      seeded = 1
    }

    text = MSG_TEXT

    if (text == "/start") {
      print("Got a start command")
      if (send_message(MSG_CHAT_ID, "👋 Hello! I'm an <b>awk-powered</b> bot. Here's what I can do:\n\n/chat_id — show current chat_id\n/random — generate a random number\n/start — show this message") == "false") {
        print("Failed to respond")
        exit(2)
      }
    }
    else if (text == "/random") {
      if (send_message(MSG_CHAT_ID, sprintf("🎲 Here's your random number: <code>%d</code>", rand() * 1000000000)) == "false") {
        print("Failed to respond")
        exit(2)
      }
    }
    else if (text == "/chat_id") {
      if (send_message(MSG_CHAT_ID, sprintf("🪪 Current chat_id: <code>%d</code>", MSG_CHAT_ID)) == "false") {
        print("Failed to respond")
        exit(2)
      }
    }
    else {
      printf("Got an unknown command: %s", text)
    }
  }
}
