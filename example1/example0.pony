use "time"

class Timeseries
  let arr : Array[I64] = Array[I64]
  fun ref add(v : I64) =>
    arr.push(v)
  fun last()? =>
    arr(arr.size()-1)?

actor PrintLastValue
  let env : Env
  new create(env' : Env) =>
    env = env'
  be print_and_inc( timeseries : Timeseries iso) =>
    let message = try
      timeseries.last()?.string()
    else
      "Timeseries is empty"
    end
    (let seconds, let nanos) = Time.now()
    timeseries.add(seconds)
    env.out.print(message)

actor Main
    new create(env : Env) =>
        let actr = PrintLastValue(env)
        let timeseries = Timeseries
        (let seconds, let nanos) = Time.now()
        timeseries.add(seconds)
        actr.print_and_inc(consume timeseries)
