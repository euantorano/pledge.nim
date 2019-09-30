# Package

version       = "2.0.0"
author        = "Euan T"
description   = "A wrapper around OpenBSD's pledge(2) systemcall for Nim."
license       = "BSD3"

srcDir = "src"

# Dependencies

requires "nim >= 1.0.0"

task docs, "Build documentation":
  exec "nim doc2 --index:on -o:docs/pledge.html src/pledge.nim"
