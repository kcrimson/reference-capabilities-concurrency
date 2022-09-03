class Counter
  var _value : I32 = 0
  fun ref inc() =>
    _value = _value+1
  fun ref dec() =>
    _value = _value-1
  fun counter() : I32 => _value

actor Incrementer
  be inc(c : Counter iso) => // pass sendable
    c.inc()  // capabiltiies sub-typing
    Decrementer.dec(consume c) //consume value

actor Decrementer
  be dec(c : Counter iso) => // pass sendable
    c.dec()  // capabiltiies sub-typing
    Incrementer.inc(consume c)

actor Main
  new create(env : Env) =>
    var c = Counter
    Incrementer.inc(consume c)
