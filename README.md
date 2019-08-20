# pledge.nim [![Travis CI Status](https://travis-ci.org/euantorano/pledge.nim.svg?branch=master)](https://travis-ci.org/euantorano/pledge.nim)

A wrapper around OpenBSD's `pledge(2)` systemcall for Nim.

## Installation

`pledge` can be installed using Nimble:

```
nimble install pledge
```

Or add the following to your `.nimble` file:

```
# Dependencies

requires "pledge >= 1.1.0"
```

## [Documentation](https://htmlpreview.github.io/?https://github.com/euantorano/pledge.nim/blob/master/docs/pledge.html)

## Usage

```nim
import pledge

pledge(Promises.Stdio)

# As we haven't used pledge to ask to access files, the below will cause the program to be temrinated with a SIGABRT.
let f = open("/etc/rc.conf")
```
