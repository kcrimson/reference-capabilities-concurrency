use "net"

class SetCommand

  let key : String
  let flags : U8
  let exptime : U32
  let value : Array[U8] val
  var _stage : Stage = _StorageCommandTextLine
  let _buffer : ReadBuffer = ReadBuffer

  new iso create(key' : String,flags' : U8, exptime' : U32, value' : Array[U8] val) =>
    key = key'
    flags = flags'
    exptime = exptime'
    value = value'

  fun request(cnn : TCPConnection)  =>
      cnn.write("set "
        +key+" "
        +flags.string()+" "
        +exptime.string()+" "
        +value.size().string()+" "
        +"\r\n"+String.from_array(value)+"\r\n")

  fun ref apply(data : Array[U8] val) : (Response | ErrorStage | PartialStage )=>
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
      | let response' : Response =>
        // we have a complete response
        return response'
      | let partial' : (PartialStage | ErrorStage) =>
        // not enough data in buffer, stop parsing
        return partial'
      | let error' : ErrorStage =>
        return error'
      end
    end
    PartialStage

class _StorageCommandTextLine
    fun val apply(buffer : ReadBuffer) : (Stage | ErrorStage | PartialStage | Response) =>
      try
        let line = buffer.line()
        match line
        | "STORED" =>
          Stored
        | "NOT_STORED" =>
          NotStored
        | "EXISTS" =>
          Exists
        | "NOT_FOUND" =>
          NotFound
        else
            ErrorStage // błąd parsowania
          end
        else
          PartialStage // buffor częściowy, nie wszystko przyszło
        end
