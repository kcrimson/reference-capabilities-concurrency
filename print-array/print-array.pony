actor Printer
  let env : Env
  let array : Array[U8] = Array[U8]
  new create(env' : Env) =>
    env = env'
  be print(char : U8) =>
    array.push(char)
    var size = array.size()
    var to_print = recover Array[U8](size) end
    for i in array.values() do
      to_print.push(i)
    end
    var str = String.from_array(consume to_print)
    env.out.print(str)

actor Main
  new create(env : Env) =>
    var printer = Printer(env)
    printer.print(0x70)
    printer.print(0x6F)
    printer.print(0x6E)
    printer.print(0x79)
