import pledge, unittest, os

suite "pledge tests":
  test  "can pledge":
    check pledge("stdio")

  test "can not elevate":
    check pledge("stdio")

    try:
      check pledge("stdio rpath") == false
      # Should never reach here
      check false
    except OSError:
      let msg = getCurrentExceptionMsg()
      check msg == "Operation not permitted"
