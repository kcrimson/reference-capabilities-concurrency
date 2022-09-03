use "files"

trait GreeterSomething
  fun greet() : String =>
    ""


interface iso Greeter
  fun greetMe(greeting : Greeting, who : String) ?

class ConsoleGreeter
  let env : Env
  new iso create(env' : Env)=>
    env = env'
  fun greetMe(greeting : Greeting, who : String) =>
    env.out.print(greeting(who))

class FileGreeter
  let env : Env
  new iso create(env' : Env) =>
    env = env'
  fun greetMe(greeting : Greeting, who : String) ? =>
    var auth = env.root as AmbientAuth
    var create_file = CreateFile(FilePath(auth,"welcome"))
    match create_file
    | let file : File =>
      try
        file.print(greeting(who))
      then
        file.dispose()
      end
    end

actor Doorkeeper
  let greeter : Greeter
  let greeting : Greeting
  new create(greeting' : Greeting, greeter' : Greeter) =>
    greeting = greeting'
    greeter = consume greeter'
  be greet(who : String) =>
    try
      greeter.greetMe(greeting,who)
    end

class val Greeting
  let greeting : String
  new val create(greeting' : String = "Hello") =>
    greeting = greeting'
  fun apply(who : String) : String =>
    greeting+" "+who+" !!!"

actor Main
  new create(env : Env) =>
    var greeter = ConsoleGreeter(env)
    Doorkeeper(Greeting("Witaj"), consume greeter).greet("world")
