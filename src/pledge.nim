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
##   pledge(Promise.Stdio)
##
## Example of making several promises
## ----------------------------------
##
## In order to pledge to use the `stdio` and `rpath` promises as described in the `pledge(2) man page <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_, you simply pass the required promises to `pledge()`:
##
## .. code-block::nim
##   import pledge
##
##   pledge(Promise.Stdio, Promise.Rpath)

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
  Mcast = "mcast",
  Fattr = "fattr",
  Chown = "chown",
  Flock = "flock",
  Unix = "unix",
  Dns = "dns",
  Getpw = "getpw",
  Sendfd = "sendfd",
  Recvfd = "recvfd",
  Tape = "tape",
  Tty = "tty",
  Proc = "proc",
  Exec = "exec",
  ProtExec = "prot_exec",
  Settime = "settime",
  Ps = "ps",
  Vminfo = "vminfo",
  Id = "id",
  Pf = "pf",
  Audio = "audio",
  Bpf = "bpf"

when defined(nimdoc):
  proc pledge*(promises: varargs[Promise]) {.raises: [OSError].} = discard
    ## Pledge to use only the defined functions. Always returns true on non-OpenBSD systems.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
elif defined(openbsd):
  proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge", header: "<unistd.h>".}

  proc promisesToString(promises: openArray[Promise]): string =
    ## Convert a list of promises to a string for use with the `pledge(2)` function.
    if len(promises) == 0:
      return ""

    let stringPromises = map(promises, proc(p: Promise): string = $p)
    result = join(deduplicate(stringPromises), " ")

  proc pledge*(promises: varargs[Promise]) {.raises: [OSError].} =
    ## Pledge to use only the defined functions. Always returns true on non-OpenBSD systems.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
    let promisesString = promisesToString(promises)

    if pledge_c(promisesString, nil) != 0:
      raiseOSError(osLastError())
else:
  proc pledge*(promises: varargs[Promise]) = discard
    ## Pledge to use only the defined functions. Always returns true on non-OpenBSD systems.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
