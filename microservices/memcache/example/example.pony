use "../../memcache"
use "collections"

actor Main
  new create(env : Env) =>
    try
      let client = MemcacheClient(env.root as AmbientAuth)

      for i in Range(0,10) do
      client
        .set("key"+i.string(),("value"+i.string()).array())
      end

      for i in Range(0,10) do
      client
        .get("key"+i.string())
        .next[None]( recover this~_onResponse(env) end )
      end

      for i in Range(0,10) do
      client
        .delete("key"+i.string())
        .next[None]( recover this~_onResponse(env) end )
      end
    end

    fun tag _onResponse(env : Env, response : Response) : None =>
      match response
      | let values : Array[Value] val =>
        for value in values.values() do
          env.out.print("value is: "+String.from_array(value.value))
        else
          env.out.print("no value")
        end
      | Deleted =>
        env.out.print("key deleted")
      end
      None
