use "collections"
use "time"

primitive Idle
primitive Busy

type ChopstickState is (Idle | Busy)

actor Chopstick
  let env : Env
  var _state : ChopstickState
  new create(env' : Env) =>
    env=env'
    _state = Idle
  be idle() =>
    None
  be busy() =>
    None

actor Philosopher
  let name : String
  let env : Env
  new create(env' : Env, name' : String) =>
    name = name'
    env = env'
  be eat() =>
    env.out.print(name.add(" is done eating."))

actor Table
  let env : Env
  let philosophers : SetIs[Philosopher] val
  new create(env' : Env, philosophers' : SetIs[Philosopher] val) => // IMPORTANT needs to sendable tag, iso, val
    env = env'
    philosophers = philosophers'
  be dine() =>
    for p in philosophers.values() do
      p.eat()
    end

actor Main
  new create(env : Env) =>
    let p1 = Philosopher(env,"Judith Butler")
    let p2 = Philosopher(env,"Gilles Deleuze")
    let p3 = Philosopher(env,"Karl Marx")
    let p4 = Philosopher(env,"Emma Goldman")
    let p5 = Philosopher(env,"Michel Foucault")
    //everything is an expression
    let p : SetIs[Philosopher] val = recover val
        let philosophers = SetIs[Philosopher](5) //default capabilite for class is ref,
        philosophers.set(p1) // receiver capabilitiy is what counts, make philosophers val and see what happens
        philosophers.set(p2) // do it outside of recover, this just sucks, http://tutorial.ponylang.org/capabilities/recovering-capabilities/
        philosophers.set(p3)
        philosophers.set(p4)
        philosophers.set(p5)
        // like return :)
        philosophers
    end
    var t = Table(env,p)
    t.dine()
