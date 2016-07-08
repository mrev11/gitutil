
function main(fspec)

local fd:=fopen(fspec)
local rl:=readlineNew(fd)
local par:=a"",line

    while( NIL!=(line:=rl:readline)  )
    
        line::=strtran(bin(13),a"")
        line::=strtran(bin(10),a"")
        line::=strtran(bin(9),a"")
        line::=alltrim

        if( par::empty() .and. line::empty() )
            loop
        elseif( !line::empty )
            par+=line+bin(10)
        else
            exit
        end
    end
    
    ?? par


