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

import os, options

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
  Video = "video",
  Bpf = "bpf",
  Unveil = "unveil",
  Error = "error"

when defined(nimdoc) or not defined(openbsd):
  proc pledge*(promises: Option[string], execPromises: Option[string] = none(string)) = discard
    ## Pledge to use only the defined functions.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.
elif defined(openbsd):
  import posix_utils, strformat

  proc pledge_c(promises: cstring, execpromises: cstring): cint {.importc: "pledge", header: "<unistd.h>".}

  type
    OpenBsdVersion = object
      major: int
      minor: int
    PledgeException* = object of Exception
    PledgeNotAvailableError* = object of PledgeException
    PledgeExecPromisesNotAvailableError* = object of PledgeException

  proc getOpenBsdVersion(): OpenBsdVersion =
    let uname = uname()

    const zero = int('0')

    result = OpenBsdVersion(
      major: int(uname.release[0]) - zero,
      minor: int(uname.release[2]) - zero,
    )

  let osVersion = getOpenBsdVersion()

  proc pledge*(promises: Option[string], execPromises: Option[string] = none(string)) =
    ## Pledge to use only the defined functions.
    ##
    ## If no promises are provided, the process will be restricted to the `_exit(2)` system call.

    # first check if pledge is available at all
    if (osVersion.major == 5 and osVersion.minor != 9) or osVersion.major < 5:
      raise newException(PledgeNotAvailableError, &"pledge(2) system call is not available on OpenBSD {osVersion.major}.{osVersion.minor}")

    # now check if execPromises is set - it's only available from openBSD 6.3+
    if (osVersion.major < 6 or (osVersion.major == 6 and osVersion.minor <= 2)) and execPromises.isSome():
      raise newException(PledgeExecPromisesNotAvailableError, &"cannot use execpromises with pledge(2) on OpenBSD {osVersion.major}.{osVersion.minor}")

    var promisesValue: cstring = if promises.isSome(): cstring(promises.get()) else: nil
    var execPromisesValue: cstring = nil

    # if running on openBSD <= 6.2, execpromises should be passed as NULL
    if osVersion.major > 6 or (osVersion.major == 6 and osVersion.minor > 2):
      execPromisesValue = if execPromises.isSome(): cstring(execPromises.get()) else: nil

    if pledge_c(promisesValue, execPromisesValue) != 0:
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
  if len(promises) > 0:
    const promisesString = getPromisesString(promises)
    pledge(some(promisesString))
  else:
    pledge(none(string))
