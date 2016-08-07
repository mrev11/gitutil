
//jöjjenek-e debug kiírások?

static debug:=getenv("GITDEBUG")

// g: git commands
// o: output of git commands
// c: callstack

***************************************************************************************
function debug(mask:="goc")  
local n,result:=""
    for n:=1 to len(debug)
        if( debug[n]$mask )
            result+=debug[n]
        end
    next
    return result


***************************************************************************************
function rundbg(cmd)
    output_of(cmd)


***************************************************************************************
