# Package

version       = "1.1.1"
author        = "Euan T"
description   = "A wrapper around OpenBSD's pledge(2) systemcall for Nim."
license       = "BSD3"

srcDir = "src"

# Dependencies

requires "nim >= 0.13.0"

task docs, "Build documentation":
  exec "nim doc2 --index:on -o:docs/pledge.html src/pledge.nim"
