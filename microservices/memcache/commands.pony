use "net"

interface _Command
  fun request(cnn : TCPConnection)
  fun ref apply(data : Array[U8] val) : (Response | ErrorStage | PartialStage)
