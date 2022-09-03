"""
Memcached server responses
"""

type Response is (
  Array[Value] val
  | Error
  | NotFound
  | Stored
  | NotStored
  | Exists
  | Deleted
  | ClientError
  | ServerError)

class val Value
  let key : String
  let flags : U8
  let size : USize
  let value : Array[U8] val
  new val create(key' : String , flags' : U8, size' : USize, value' : Array[U8] val) =>
    key = key'
    flags = flags'
    size = size'
    value = value'

class val ClientError
  let message : String
  new val create(message' : String) =>
    message=message'

class val ServerError
  let message : String
  new val create(message' : String) =>
    message=message'

primitive Error

primitive Deleted

primitive Stored

primitive NotStored

primitive Exists

primitive NotFound
