# Package

version       = "1.0.2"
author        = "Euan T"
description   = "A wrapper around OpenBSD's pledge(2) systemcall for Nim."
license       = "BSD3"

srcDir = "src"

# Dependencies

requires "nim >= 0.13.0"

task tests, "Run unit tests":
  exec "nim c -r tests/main"

task docs, "Build documentation":
  exec "nim doc --index:on -o:docs/pledge.html src/pledge.nim"
