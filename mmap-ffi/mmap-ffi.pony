use "files"

use @mmap[Pointer[U8]](addr : Pointer[U8], length : U64, prot : I32, flags : I32, fd : I32, off_t : I64)
use @open[I32](name : Pointer[U8] tag,flags :U16)
use @close[I32](fd : I32)



primitive ProtWrite
  fun value():I32 => 2

primitive ProtRead
  fun value():I32 => 2

type Prot is (ProtWrite | ProtRead)

class MMap
  new create(env : Env) =>
    let fd : I32 = @open("jarek".cstring(),2)
    let p = @mmap(Pointer[U8].create(),1024*1024,2,1,fd,0)
    if p.is_null() then
      env.out.print("failed to map memory")
    end
    let arr = Array[U8].from_cstring(p,1024,1024)
    try
      arr.update(0,164)
      arr.update(1,164)
      arr.update(2,164)
    end
    env.out.print("it works")

actor Main
  new create(env : Env) =>
    MMap(env)
