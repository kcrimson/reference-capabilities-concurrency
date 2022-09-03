use "promises"

interface ObjectInPoolFactory[A]
  fun create() : A

actor ObjectCachedPool[A:Any #share] //NOTE: parameter constraints and what is #share?
  """
    This is really basic pool, which just caches objects, so in fact it can grow endlessly.
    TODO: implement object cleaner, for objects which are long in a pool, not used
    TODO: this implementation can also leak objects as we do not maintaint list
      of checked out objects, silly me!
    TODO: object can be checked out from pool forever, there is no timeout,
      in short, we need a way to close objects which are outside of the pool for
      too long ( something like Closeable :), but is it really possible with
      Pony's memory safety? Man, my brain hurts, this is so different.
      Shit, I'm talking to myself :)
  """
  let _unused : Array[A] = Array[A]()
  let _factory : ObjectInPoolFactory[A] val
  new create(factory' : ObjectInPoolFactory[A] val) =>
     _factory = factory'

  be checkout(p : Promise[A]) =>
    let obj = try _unused.pop() else _factory.create() end //NOTE: everything is expression
    p(obj) //NOTE: synctatic sugar with apply function :)

  be checkin(obj : A) =>
    _unused.push(obj)
