use "ponytest"
use "net"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_GetCommandSingleValueTest)
    test(_GetCommandMultipleValueTest)

class iso _GetCommandSingleValueTest is UnitTest

  fun name(): String => "memcache/GetCommand/single value"

  fun apply(h: TestHelper) ? =>
    let response= "VALUE key 0 5\r\nvalue\r\nEND\r\n".array()
    let command = _GetCommand("key")
    let resp = command(response)
    let values = resp as Array[Value] val
    let value = values(0)
    h.assert_eq[String](value.key,"key")
    h.assert_eq[U8](value.flags,0)
    h.assert_eq[USize](value.size,5)
    h.assert_array_eq[U8](value.value,"value")

class iso _GetCommandMultipleValueTest is UnitTest

  fun name(): String => "memcache/GetCommand/multiple value"

  fun apply(h: TestHelper) ? =>
    let response= "VALUE key 0 5\r\nvalue\r\nVALUE key0 0 6\r\nvalue0\r\nEND\r\n".array()
    let command = _GetCommand("key0")
    let resp = command(response)
    let values = resp as Array[Value] val
    var value = values(0)
    h.assert_eq[String](value.key, "key")
    h.assert_eq[U8](value.flags,0)
    h.assert_eq[USize](value.size,5)
    h.assert_array_eq[U8](value.value,"value")

    value = values(1)
    h.assert_eq[String](value.key, "key0")
    h.assert_eq[U8](value.flags,0)
    h.assert_eq[USize](value.size,6)
    h.assert_array_eq[U8](value.value,"value0")
