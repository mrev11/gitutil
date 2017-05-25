

function username()

local un

    if( empty(un) )
        un:=getenv("GITUSER") //custom
    end

    if( empty(un) )
        un:=getenv("USER") //Linux
    end

    if( empty(un) )
        un:=getenv("USERNAME") //Windows
    end

    return un






