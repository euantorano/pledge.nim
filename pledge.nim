# pledge(2) for Nim

import os

when defined(openbsd):
  proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge".}

  proc pledge*(promises: string): bool {.raises: [OSError].} =
    ## Pledge to use only the defined functions, separated by a space. Always returns true on non-OpenBSD systems.
    let pledged = pledge_c(promises, nil)

    if pledged != 0:
      let errorCode = osLastError()
      raiseOSError(errorCode)

    return pledged == 0
else:
  proc pledge*(promises: string): bool =
    ## Pledge to use only the defined functions, separated by a space. Always returns true on non-OpenBSD systems.
    return true
