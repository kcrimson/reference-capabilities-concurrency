use "files"
use "collections"

actor GroupBy
  let result : Map[String, I64] = Map[String,I64]
  new create() =>
    """"""
  be groupBy(row : (String,I64)) =>
    if result.contains(row[0]) then

actor LineProcessor
  let env : Env
  new create(env' : Env) =>
    env = env'
  be process(line : String) =>
    var arr = line.split(",")
    try
      var product_name = arr(0)
      var count = arr(1)
    end

actor FileReader
  var file : (File | None)
  let env : Env
  new create(root : AmbientAuth,filename : String val, env' : Env) =>
    env = env'
    file =
    try
      File(FilePath(root,filename))
    else
      None
    end
  be process() =>
    match file
    | let f : File =>
      try
        var line = f.line()
        LineProcessor(env).process(consume line)
        process()
      end
    end

actor Main
  new create(env : Env) =>
    try
      let root = env.root as AmbientAuth
      FileReader(root,"random_products.csv", env).process()
    end
