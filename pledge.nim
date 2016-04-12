# pledge(2) for Nim

proc pledge_c(promises, paths: cstring): cint {.importc: "pledge".}

proc pledge*(promises: string): bool =
    ## Pledge to use only the defined functions, separated by a space.
    let pledged = pledge_c(promises, nil)
    return pledged == 0