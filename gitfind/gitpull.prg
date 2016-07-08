
#include "directry.ch"



*****************************************************************************
function main()

    set dosconv off
    
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
            run("git pull")
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
