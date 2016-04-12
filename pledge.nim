# pledge(2) for Nim

from os import osLastError, raiseOSError
from sequtils import map, deduplicate
from strutils import join

type Promise* {.pure.} = enum
  ## The possible operation sets that a program can pledge to be limited to.
  Stdio = "stdio",
  Rpath = "rpath",
  Wpath = "wpath",
  Cpath = "cpath",
  Dpath = "dpath",
  Tmppath = "tmppath",
  Inet = "inet",
  Fattr = "fattr",
  Flock = "flock",
  Unix = "unix",
  Dns = "dns",
  Getpw = "getpw",
  Sendfd = "sendfd",
  Recvfd = "recvfd",
  Ioctl = "ioctl",
  Tty = "tty",
  Proc = "proc",
  Exec = "exec",
  Prot_exec = "prot_exec",
  Settime = "settime",
  Ps = "ps",
  Vminfo = "vminfo",
  Id = "id",
  Pf = "pf",
  Audio = "audio"

when defined(openbsd):
  proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge".}

  proc promisesToString(promises: openArray[Promise]): string =
    ## Convert a list of promises to a string for use with the `pledge(2)` function.
    let stringPromises = map(promises, proc(p: Promise): string = $p)
    return join(deduplicate(stringPromises), " ")

  proc pledge*(promises: openArray[Promise]): bool {.raises: [OSError].} =
    ## Pledge to use only the defined functions, separated by a space. Always returns true on non-OpenBSD systems.
    let promisesString = promisesToString(promises)
    let pledged = pledge_c(promises, nil)

    if pledged != 0:
      let errorCode = osLastError()
      raiseOSError(errorCode)

    return pledged == 0
else:
  proc pledge*(promises: openArray[Promise]): bool =
    ## Pledge to use only the defined functions, separated by a space. Always returns true on non-OpenBSD systems.
    return true
