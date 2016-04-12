import pledge, unittest

suite "pledge tests":
  test  "can pledge":
    check pledge("stdio")

  test "can not elevate":
    check pledge("stdio")
    check pledge("stdio rpath") == false

  test "can pledge and not read file":
    ## This test should cause the tests to abort, as the kernel will kill us for trying to access the file.
    check pledge("stdio")
    let f = open("/etc/rc.conf")