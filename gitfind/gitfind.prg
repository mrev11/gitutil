
#include "directry.ch"

static cmd


*****************************************************************************
function main(*)

    if( 0<ascan({*},"-p") )
        cmd:="git pull"
    else
        cmd:="git status -s"
    end
    
    doproc() 
    ?

*****************************************************************************
static function doproc()    

local name,n,d,d1:={}


    d:=directory(fullmask(),"D")
    
    for n:=1 to len(d)
        name:=alltrim(d[n][F_NAME])

        if( !"D"$d[n][F_ATTR] )
            //nem directory
        elseif( name=="." )
        elseif( name==".." )
        elseif( "ARCHIVE"$name)

        elseif( name==".git" )
            ? "--------------------------------------------------------------------"
            ? curdir();?
            run(cmd)
        else
            aadd(d1,name)
        end
    next
   
    d:=NIL
    
    for n:=1 to len(d1)
        name:=d1[n] 
        if( 0<=dirchange(name) )
             doproc()
             dirchange("..")
        end
    next

*****************************************************************************
