use "net/http"
use "memcache"
use "promises"

actor Main
  new create(env : Env) =>

    let serverNotify : ServerNotify iso = _NoOpServerNotify
    let limit:USize = 2000

    try
    var ambientAuth = env.root as AmbientAuth
    var client = MemcacheClient(ambientAuth,env)
    Server.create(
          ambientAuth,
          consume serverNotify,
          _MemcacheProxyRequestHandler(consume client),
          CommonLog(env.out),
          "localhost",
          "8080",
          limit)
    end

class _NoOpServerNotify is ServerNotify

class _MemcacheResponseHandler
  var _payload : Payload
  new iso create(payload' : Payload) =>
    _payload = consume payload'
  fun ref apply(s: (Value | None)): None =>
    var response =
    match s
    | let value : Value =>
      var response = Payload.response()
      response.add_chunk(value.value)
      consume response
    else
      Payload.response(404,"NOT FOUND")
    end
    var payload = _payload = Payload.response()
    (consume payload).respond(consume response)

class _MemcacheProxyRequestHandler
  let _client : MemcacheClient
  new val create(client' : MemcacheClient) =>
    _client = client'

  fun val apply(request: Payload): Any =>
    let path = request.url.path
    let method = request.method
    let key : String val = path.cut(0,1)
    match method
    | "GET" =>
      var r = _MemcacheResponseHandler(consume request)
      _client.get(key).next[(Value | None)](consume r)
    end
