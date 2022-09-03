primitive Bytecode
  fun hlt() : U8 => 1
  fun print() : U8 => 2
  fun iconst() : U8 => 3
class VM
  var env : Env
  var code : Array[U8] val
  var data : Array[U8]
  var ip : USize
  var sp : USize
  var fp : USize
  new create(env' : Env, code' : Array[U8] val,data_size : USize, ip' : USize) =>
    env = env'
    code = code'
    data = Array[U8](data_size)
    ip = ip'
    sp = -1
    fp = 0
  fun ref cpu() ? =>
    while ip<code.size() do
      var opcode = code(ip)
      ip = ip + 1
      match opcode
      | Bytecode.hlt() => return
      | Bytecode.print() =>
        
        env.out.print("Hi interpreter")
      | Bytecode.iconst() =>
        var const = code(ip)
        ip=ip+1
        sp=sp+1
        data(sp)=const
      else
        // this shouldn't happen
        return
      end
    end

actor Main
  new create(env : Env) =>
    var code =
    recover val
      Array[U8]
      .push(Bytecode.print())
      .push(Bytecode.hlt())
    end
    try
      VM(env,code,1024,0).cpu()
    end
