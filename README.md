# pledge.nim

A wrapper around OpenBSD's pledge(2) systemcall for Nim.

## Installation

This package can be installed using `nimble`:

```
nimble install pledge
```

## Usage

```nim
import pledge

if not pledge(Promises.Stdio):
  # Pledge failed, cannot use stdio
  quit(QuitFailure)

# As we haven't used pledge to ask to access files, the below will cause the program to be temrinated.
let f = open("/etc/rc.conf")
```
