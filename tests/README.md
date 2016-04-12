# Using these tests

These tests can be ran by invoking:

`nim c -r tests/main.nim`

From the root directory. The test `can pledge and not read file` should fail as it should cause the program to be killed by the kernel.