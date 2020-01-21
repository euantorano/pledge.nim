# pledge.nim [![builds.sr.ht status](https://builds.sr.ht/~euantorano.svg?search=pledge.nim)](https://builds.sr.ht/~euantorano?search=pledge.nim)

A wrapper around OpenBSD's `pledge(2)` system call for Nim.

Includes support for OpenBSD's `unveil(2)` system call.

## Installation

`pledge` can be installed using Nimble:

```
nimble install pledge
```

Or add the following to your `.nimble` file:

```
# Dependencies

requires "pledge >= 2.0.0"
```

## Usage

```nim
import pledge

pledge(Promises.Stdio)

# As we haven't used pledge to ask to access files, the below will cause the program to be terminated with a SIGABRT.
let f = open("/etc/rc.conf")
```
