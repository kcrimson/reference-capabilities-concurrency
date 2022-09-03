use "net"
use "collections"
use "promises"

class val MemcacheClient

  var connection : _ClientConnection

  new val create(ambientAuth : AmbientAuth) =>
    // in fact we should pool client connections or pooling should happen deeper ? it depends
    connection = _ClientConnection(ambientAuth)

  fun get(key : String): Promise[Response] =>
    var promise = Promise[Response]
    var cmd = _GetCommand(key)
    connection.execute(consume cmd, promise)
    promise

  fun set(key : String, value : Array[U8] val, exptime : U32 = 0, flags : U8 = 0): Promise[Response] =>
      var promise = Promise[Response]
      var cmd = SetCommand(key, 0, 0, value)
      connection.execute(consume cmd, promise)
      promise

  fun delete(key : String): Promise[Response] =>
    var promise = Promise[Response]
    var cmd = DeleteCommand(key)
    connection.execute(consume cmd, promise)
    promise

actor _ClientConnection
  """
    A logical connection to memcached server, it wrapps TCPConnection,
    providing queue of commands.
  """

  let host : String
  let service : String

  let _ambientAuth : AmbientAuth
  let _enqueued : List[(_Command iso, Promise[Response])] = List[(_Command iso, Promise[Response])]
  var _pending : ((_Command, Promise[Response]) | None) = None
  var _cnn : (TCPConnection | None) = None

  new create(
    ambientAuth' : AmbientAuth,
    host' : String = "localhost",
    service' : String = "11211"
    ) =>
    _ambientAuth = ambientAuth'
    host = host'
    service = service'

  be execute(command: _Command iso, promise : Promise[Response]) =>
    """ schedules command for execution """
    if _pending is None then
      // there is no pending command, eat this shit and send it to server
      try
        _request(consume command, promise)
      end
      // TODO actually we should handle if TCPConnection is None
    else
      // we are already waiting for response, schedule as next command
      // this is the place where we can say back off, when queue is to
     // big, but how does it fit pony model?
      _enqueued.push((consume command,promise))
    end

  be response(data : Array[U8] val) =>
    try
      //get current pending command, pass received data, and handle it
      (let command,let promise) = (_pending as (_Command,Promise[Response]))
      let result = command(consume data)
      if result is PartialStage then
        return
      elseif result is ErrorStage then
        promise.reject()
        // that's wrong, the connection is in unknown stage,
        // it would be better to close this connection
      else
        // hell yeah we have response, we can fulfill the promise :)
        promise(result as Response)
        _pending = None
      end
    end

    // send next queued command
    try
      (let command,let promise) = _enqueued.shift()
      _request(consume command, promise)
    end

  fun ref _ensure_connection() =>
    """ ensures actual TCPConnection connection is up and connected """
    if _cnn is None then
        _cnn = TCPConnection(_ambientAuth,_ClientConnectionNotify(this),host,service)
    end

  fun ref _request(command : _Command iso, promise : Promise[Response]) ? =>
    _ensure_connection()
    command.request(_cnn as TCPConnection)
    _pending = (consume command, promise)

class _ClientConnectionNotify is TCPConnectionNotify

  var _clientConnection : _ClientConnection

  new iso create(clientConnection : _ClientConnection) =>
    _clientConnection=clientConnection

  fun ref received(conn: TCPConnection ref, data: Array[U8] iso) =>
    _clientConnection.response(consume data)
