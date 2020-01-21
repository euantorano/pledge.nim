# Package

version       = "2.0.1"
author        = "Euan T"
description   = "A wrapper around OpenBSD's pledge(2) systemcall for Nim."
license       = "BSD3"

srcDir = "src"

# Dependencies

requires "nim >= 1.0.0"

task test, "Runs the test suite":
    exec "nim c -r tests/main"
