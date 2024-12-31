
#include "directry.ch"

static basename:="buildnumber_*.prg"


function main()
local bnspec,text,offs,bnum
    bnspec:=search(".")
    if( bnspec!=NIL )
        text:=memoread(bnspec)
        offs:=at("return",text)
        bnum:=text::substr(offs+6)::val
        memowrit(bnspec,"function "+fname(bnspec)+"();return"+str(bnum+1))
        //run( "cat "+bnspec );?
        ?? bnspec, bnum+1
    end
    

function search(dir)
local d,d1:={},f,n

    d:=directory( dir+dirsep()+fullmask(),"D" )
    
    for n:=1 to len(d)
        f:=d[n]
        if( like(basename,f[F_NAME]) )
            return dir+dirsep()+f[F_NAME]
        elseif( "D"$f[F_ATTR] )
            if( "L"$f[F_ATTR] )
            elseif( f[F_NAME]=="." )
            elseif( f[F_NAME]==".." )
            else
                d1::aadd(f[F_NAME])
            end
        end
    next        

    for n:=1 to len(d1)
        d:=search(dir+dirsep()+d1[n])
        if( d!=NIL  )
            return d
        end
    next
        