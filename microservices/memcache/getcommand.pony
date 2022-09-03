use "net"

class _GetCommand

    let key : String
    let _buffer : ReadBuffer = ReadBuffer
    var _stage : Stage = _TextLine
    let _values : Array[Value] = Array[Value]

    new iso create(key' : String) =>
      key=key'

    fun request(cnn : TCPConnection)  =>
      """
      Sends GET command to server, over provided TCP connection
      """
      cnn.write("get "+key+" \r\n")

    fun ref apply(data : Array[U8] val): (Response | ErrorStage | PartialStage) =>
        // append data to local read buffer
        _buffer.append(data)
        //until data is available
        while _buffer.size()>0 do
          //try to parse available data
          let result = _stage(_buffer)
          match result
          | let stage' : Stage =>
            // move to a next stage of parsing
            _stage = stage'
          | let value' : Value =>
            // push received value
            _values.push(value')
            // and reset parsing stage
            _stage = _TextLine
            continue
          | let nonce': EndStage =>
            let values = recover Array[Value] end
            for value in _values.values() do
              values.push(value)
            end
            return consume values
          | let nonce' : (PartialStage | ErrorStage) =>
            // not enough data in buffer or error during parsing,
            return nonce'
          end
        end
        PartialStage

class _TextLine

  fun val apply(buffer : ReadBuffer) : (Stage | ErrorStage | PartialStage | EndStage | Value | Response) =>
    try
      let line = buffer.line()
      let parsed_line : Array[String] = line.split(" ")
      let status = parsed_line(0) // actually do a check if size is correct
      match status
      | "VALUE" =>
        // we have a value, hey let's parse it
        let key = parsed_line(1)
        let flags = parsed_line(2).u8()
        let size = parsed_line(3).usize()
        _DataBlock(key,flags,size) // parsuj buffor i podaj dalej
      | "END" =>
        EndStage
      | "CLIENT_ERROR" =>
        ClientError(parsed_line(1))
      else
        ErrorStage // błąd parsowania
      end
    else
      PartialStage // buffor częściowy, nie wszystko przyszło
    end

class _DataBlock
  let key : String
  let flags : U8
  let size : USize
  new val create(key' : String, flags' : U8, size' : USize) =>
    key=key'
    flags=flags'
    size=size'
  fun val apply(buffer : ReadBuffer) : (Stage | ErrorStage | PartialStage) =>
    if buffer.size() < size then
      PartialStage
    else
      try
        let value = buffer.block(size)
        _EndOfDataBlock(Value(key,flags,size,consume value))
      else
        ErrorStage
      end
    end

class _EndOfDataBlock
  let value : Value
  new val create(value' : Value) =>
    value=value'
  fun val apply(buffer : ReadBuffer) : (ErrorStage | PartialStage | Value) =>
    try
      let line = buffer.line()
      if line=="" then
        value
      else
        ErrorStage
      end
    else
      PartialStage
    end
