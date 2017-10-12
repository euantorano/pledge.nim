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

import os

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

when defined(nimdoc) or not defined(openbsd):
  proc pledge*(promises: string) = discard
    ## Pledge to use only the defined functions.
    ##
    ## The `promises` parameter is a string of space separated promises as described in the `pledge(2) man page <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
elif defined(openbsd):
  proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge", header: "<unistd.h>".}

  proc pledge*(promises: string) =
    ## Pledge to use only the defined functions.
    ##
    ## The `promises` parameter is a string of space separated promises as described in the `pledge(2) man page <http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge>`_.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
    ##
    ## If the pledge call is not successful, an `OSError` will be thrown.
    if pledge_c(promises, nil) != 0:
      raiseOSError(osLastError())

proc getPromisesString(promises: openarray[Promise]): string {.compiletime.} =
  result = ""

  var
    promiseSet: set[Promise] = {}
    sep = ""

  for p in promises:
    if p notin promiseSet:
      promiseSet.incl(p)
      result.add(sep)
      result.add($p)

      sep = " "

template pledge*(promises: varargs[Promise]) =
  ## Pledge to use only the defined functions.
  ##
  ## This template takes a list of `Promise`, creates the required promise string and emits a call to the `pledge` proc.
  const promisesString = getPromisesString(promises)
  pledge(promisesString)
