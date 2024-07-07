@include "util.awk"

function http_request(server, port, type, path, headers, body, rs) {
  gsub("\n", "%0A", path)
  gsub(" ", "%20", path)
  request = sprintf("%s %s HTTP/1.1\n\
%s\n\
\n\
%s", type, path, headers, body)

  gsub("\n", "\r\n", request)

  print(request)
  print("Opening a socket")
  socket = sprintf("/inet/tcp/0/%s/%d", server, port)

  print("Sending data to the socket")
  printf("%s", request) |& socket
  print("Retrieving the response")
  socket |& getline resp
  printf("Response header: %s\n", resp)

  for (i = 0; 1; i++) {
    socket |& getline header
    gsub("\r", "", header)
    if (header == "") {
      break
    }

    match(header, /(.*): (.*)/, keyval)

    resp_headers[keyval[1]] = keyval[2]
  }

  body = ""
  count = 0
  printf("Reading body (length: %d)\n", resp_headers["Content-Length"])
  _rs = RS
  RS = rs
  while ((socket |& getline line) > 0) {
    print(line)
    count += length(line) + 1
    gsub("\r", "", line)
    body = sprintf("%s%s%s", body, line, RS)
    if (count == resp_headers["Content-Length"]) {
      break
    }
  }
  RS = _rs
  close(socket)

  return body
}

function http_get(server, port, uri, rs) {
  printf("Performing GET on http://%s:%d%s\n", server, port, uri)
  socket = "/inet/tcp/0/localhost/1488"

  headers[0] = "User-Agent: cc.winogrona.awkhttp/1.0"
  headers[1] = "Host: " server ":" port
  headers[2] = "Accept: text/json"
  headers[3] = "Connection: close"

  return http_request(server, port, "GET", uri, join(headers, "\n"), "", rs)
}

BEGIN {
}
