@include "http.awk"
@include "JSON.awk"

BEGIN {
  TG_RT_OFFSET = 0
}

function tg_request(method, args) {
  args_str = ""
  for (i in args) {
    args_str = args_str "&" args[i]
  }
  
  resp = http_get(TG_SERVER, TG_PORT, \
  sprintf("/bot%s/%s?%s", TG_TOKEN, method, args_str), "}")
  
	tokenize(resp)
  if (parse() != 0) {
    print("JSON parse error")
    exit(1)
  }

  return JSON_RESULT["'ok'"]
}

function poll() {
  args[0] = sprintf("offset=%d", TG_RT_OFFSET)
  args[1] = "limit=1"
  args[2] = "timeout=10"
  args[3] = "allowed_updates=[\"message\"]"
  
  if (tg_request("getUpdates", args) == "false") {
    return "error"
  }

  delete args

  if (JSON_RESULT["'result'"] == "[]") {
    return("empty")
  }

  TG_RT_OFFSET = JSON_RESULT["'result',0,'update_id'"] + 1
  printf("New offset: %d\n", TG_RT_OFFSET)


  text = JSON_RESULT["'result',0,'message','text'"]
  match(text, /"(.*)"/, group)
  MSG_TEXT = group[1]
  MSG_CHAT_ID = JSON_RESULT["'result',0,'message','chat','id'"]

  return "ok"
}

function send_message(chat_id, msg_text) {
  gsub("&", "\\&", msg_text)
  printf("Sending: [%s] to %d", msg_text, chat_id)

  delete args

  args[0] = "chat_id=" chat_id
  args[1] = "text=" msg_text
  args[2] = "parse_mode=HTML"

  resp = tg_request("sendMessage", args)
  delete args
  return resp
}
