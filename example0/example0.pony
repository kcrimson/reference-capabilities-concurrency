use "collections"

class AnObject
  let arr : Array[U8] = Array[U8]
  fun add(v : U8) =>
    arr.push(v)

actor Main
    new create(env : Env) =>
        let anObject = AnObject
        anObject.add(1)
