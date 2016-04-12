# pledge(2) for Nim

import os

proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge".}

proc pledge*(promises: string): bool {.raises: [OSError].} =
  ## Pledge to use only the defined functions, separated by a space.
  let pledged = pledge_c(promises, nil)

  if pledged != 0:
    let errorCode = osLastError()
    raiseOSError(errorCode)

  return pledged == 0