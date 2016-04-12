# pledge(2) for Nim

proc pledge_c(promises: cstring, paths: cstringArray): cint {.importc: "pledge".}

proc pledge*(promises: string): bool =
    ## Pledge to use only the defined functions, separated by a space.
    # TODO: Paths
    let pledged = pledge_c(promises, nil)
    return pledged == 0
