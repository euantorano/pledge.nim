## A wrapper for the `pledge(2) <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_ systemcall, used to restrict system operations.
##
## On systems other than OpenBSD where `pledge` is not yet implemented, the wrapper has no effect.
##
## Example of making a single promise
## ----------------------------------
##
## In order to pledge to only use the `stdio` promise as described in the `pledge(2) man page <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_, you simply pass the `Promise.Stdio` to `pledge()`:
##
## .. code-block::nim
##   import pledge
##
##   let pledged = pledge(Promises.Stdio)
##
## Example of making several promises
## ----------------------------------
##
## In order to pledge to use the `stdio` and `rpath` promises as described in the `pledge(2) man page <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_, you simply pass the required promises to `pledge()`:
##
## .. code-block::nim
##   import pledge
##
##   let pledged = pledge(Promises.Stdio, Promises.Rpath)

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

when defined(nimdoc):
  proc pledge*(promises: varargs[Promise]): bool {.raises: [OSError].} = discard
    ## Pledge to use only the defined functions. Always returns true on non-OpenBSD systems.
    ##
    ## If the pledge call was successful, this will return true.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
elif defined(openbsd):
  proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge".}

  proc promisesToString(promises: openArray[Promise]): string =
    ## Convert a list of promises to a string for use with the `pledge(2)` function.
    let stringPromises = map(promises, proc(p: Promise): string = $p)
    return join(deduplicate(stringPromises), " ")

  proc pledge*(promises: varargs[Promise]): bool {.raises: [OSError].} =
    let promisesString = promisesToString(promises)
    let pledged = pledge_c(promisesString, nil)

    if pledged != 0:
      let errorCode = osLastError()
      raiseOSError(errorCode)

    result = true

else:
  proc pledge*(promises: varargs[Promise]): bool = true
