use "net"

class DeleteCommand

  let key : String
  var _stage : Stage = _DeleteCommandTextLine
  let _buffer : ReadBuffer = ReadBuffer

  new iso create(key' : String) =>
    key = key'

  fun request(cnn : TCPConnection)  =>
    cnn.write("delete "+key+" \r\n")

    fun ref apply(data : Array[U8] val): (Response | ErrorStage | PartialStage)=>
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
          | let nonce' : (PartialStage | ErrorStage) =>
            // not enough data in buffer, stop parsing
            return nonce'
          end
        end
        PartialStage

class _DeleteCommandTextLine
  fun val apply(buffer : ReadBuffer) : (Stage | ErrorStage | PartialStage | Response) =>
    try
      let line = buffer.line()
      match line
      | "DELETED" =>
        Deleted
      | "NOT_FOUND" =>
        NotFound
      else
        ErrorStage // błąd parsowania
      end
    else
      PartialStage // buffor częściowy, nie wszystko przyszło
  end
