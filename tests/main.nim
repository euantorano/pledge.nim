import pledge, unittest

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
      unveil("", {})

      var f: File
      check not open(f, "/dev/zero", fmRead)

suite "pledge tests":
  test "can pledge":
    pledge(Promise.Stdio, Promise.Rpath, Promise.Unveil)

    check true

  when defined(openbsd):
    test "can not elevate":
      pledge(Promise.Stdio, Promise.Unveil)

      expect OSError:
        pledge(Promise.Stdio, Promise.Rpath, Promise.Unveil)
