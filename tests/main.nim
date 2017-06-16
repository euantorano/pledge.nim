import pledge, unittest, os

suite "pledge tests":
  test "can pledge":
    pledge(Promise.Stdio, Promise.Rpath)

    check true

  when defined(openbsd):
    test "can not elevate":
      pledge(Promise.Stdio)

      expect OSError:
        pledge(Promise.Stdio, Promise.Rpath)
