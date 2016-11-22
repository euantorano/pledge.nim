import ../pledge, unittest, os

suite "pledge tests":
  test  "can pledge":
    check pledge(Promise.Stdio, Promise.Rpath)

  when defined(openbsd):
    test "can not elevate":
      check pledge(Promise.Stdio)

      expect OSError:
        check pledge(Promise.Stdio, Promise.Rpath) == false
