

static version:=init_version()

******************************************************************************
static function init_version()
local v:=output_of("git --version")
    v::=strtran(" ",".")
    v::=split(".")
    v:=v[3..5]
    v[1]::=val
    v[2]::=val
    v[3]::=val
    return v      //pl. {git,version,2,10,0,windows,1}

******************************************************************************
function gitversion(op,ver)  //ver={2,10,0} szamokkal

    if( op==NIL )
        return version

    elseif( op=="gt" )
        return cmp(ver)==.t.
    elseif( op=="ge" )
        return cmp(ver)!=.f.
    elseif( op=="lt" )
        return cmp(ver)==.f.
    elseif( op=="le" )
        return cmp(ver)!=.t.
    end


******************************************************************************
static function cmp(ver)

    if( version[1]>ver[1] )
        return .t.
    elseif( version[1]<ver[1] )
        return .f.

    elseif( version[2]>ver[2] )
        return .t.
    elseif( version[2]<ver[2] )
        return .f.

    elseif( version[3]>ver[3] )
        return .t.
    elseif( version[3]<ver[3] )
        return .f.

    else
        return NIL
    end

******************************************************************************

