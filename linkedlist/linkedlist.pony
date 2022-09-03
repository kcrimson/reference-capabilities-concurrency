class LinkedList[A : (Any #share)]
  var _head : (_Node[A] | None) = None

  fun ref add(value : A) : LinkedList[A] =>
    var node = _Node[A](value)
    this

  fun empty() : Bool =>
    match _head
    | None => true
    else
      false
    end

class _Node[A : (Any #share)]
  let value : A
  var next : (_Node[A] | None) = None
  new create(value' : A) =>
    value = value'

actor Main
  new create(env : Env) =>
    var list = LinkedList[String]
    list.add("Hello")
