

function username()

local un

#ifndef WINDOWS
    un:=getenv("USER")
#else
    un:=getenv("USERNAME")
#endif

    return un



