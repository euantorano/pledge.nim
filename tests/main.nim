import pledge, unittest, os

suite "pledge tests":
  test  "can pledge":
    check pledge([Promise.Stdio])

  when defined(openbsd):
    test "can not elevate":
      check pledge([Promise.Stdio])

      try:
        check pledge([Promise.Stdio, Promise.Rpath]) == false
        # Should never reach here
        check false
      except OSError:
        let msg = getCurrentExceptionMsg()
        check msg == "Operation not permitted"
  else:
    test "can not elevate":
      check pledge([Promise.Stdio])

      try:
        check pledge([Promise.Stdio, Promise.Rpath])
      except OSError:
        let msg = getCurrentExceptionMsg()
        check msg == "Operation not permitted"
