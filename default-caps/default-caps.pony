class A
  fun apply() : String =>
    "I am A"

class B
  fun apply() : String =>
    "I am B"

class C
  fun applyOnA(a : A) : String =>
    a()
  fun applyOnB(b : B) : String =>
    b()

actor Main
  new create(env : Env) =>
    """
    """
