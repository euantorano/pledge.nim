# Package

version       = "1.0.1"
author        = "Euan T"
description   = "A wrapper around OpenBSD's pledge(2) systemcall for Nim."
license       = "BSD"

# Dependencies

requires "nim >= 0.13.0"

task tests, "Run unit tests":
  exec "nim c -r tests/main"

task docs, "Build package documentation":
  exec "nim doc2 pledge.nim"