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

suite "unveil tests":
  test "can access path that is unveiled":
    unveil("/dev/urandom", {Permission.Read})

    var f: File
    check open(f, "/dev/urandom", fmRead)
    var buff: array[0..9, byte]
    check f.readBytes(buff, 0, len(buff)) > 0

  when defined(openbsd):
    test "can't access path that isn't unveiled":
      unveil("/dev/urandom", {Permission.Read})

      expect OSError:
        var f: File
        open(f, "/dev/zero", fmRead)
