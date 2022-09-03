use "net"

interface val Stage
  fun val apply(buffer : ReadBuffer) : (Stage | ErrorStage | PartialStage | EndStage | Value | Response)

primitive PartialStage

primitive ErrorStage
  """
  Response parsing ended up in unrecoverable state
  """

primitive EndStage
