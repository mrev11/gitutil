
#include "inkey.ch"

static context:="3" //a változások körül megjelenített sorok száma


********************************************************************************************
function view_diff(parbrw,arg_commit1,arg_commit2)

local arr:=brwArray(parbrw)
local pos:=brwArrayPos(parbrw)
local fname:=arr[pos][2]

local crs:=setcursor(1)
local scrn:=savescreen()
local rl,line,changes:={}
local brw
local gitcmd

local mode:="dif"

while( mode!=NIL )

    changes:={}
    gitcmd:="git diff -U"+context
    gitcmd+=" "+arg_commit1
    gitcmd+=" "+arg_commit2
    gitcmd+=" -- "+fname

    rl:=read_output_of(gitcmd)
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        line::=strtran(chr(10),"")
        
        if("@@"==line[1..2])
            pos:=rat("@@",line)
            if( 2<pos )
                line::=left(pos+1)
                //azt hiszem, hogy C szintaxist feltételezve
                //az aktuális függvény nevét akarja odaírni,
                //de ez CCC-ben nem működik, levágom
            end
        end
        
        if( mode=="dif" )
            changes::aadd({line})
        elseif( mode=="old" .and. !line[1]=="+" )
            changes::aadd({line})
        elseif( mode=="new" .and. !line[1]=="-" )
            changes::aadd({line})
        end
    end
    rl:close

    if(empty(changes))
        aadd(changes,{"no changes"})
    end


    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwMenuName(brw,"["+fname+"]")
    brwArray(brw,changes)
    brwColumn(brw,"", brwAblock(brw,1),replicate("X",maxcol()-2))

    brwMenu(brw,"Diff","Diff mode" ,{||mode:="dif",.f.})
    brwMenu(brw,"Old","Old version",{||mode:="old",.f.})
    brwMenu(brw,"New","New version",{||mode:="new",.f.})
    brwMenu(brw,"Context-"+context,"Number of lines around changes",{||context::=getcontext,.f.})
    
    brw:colorspec:="w/n,n/w,r+/n,g+/n,w+/n,bg+/n"
    //              1   2   3    4    5    6

    brw:getcolumn(1):colorblock:={|x|diffcolor(x)}
    
    brw:headsep:="" //nincs oszlopnév!
    brw:cargo[12]:=.f.  //BR_HIGHLIGHT nincs rá API

    brwApplyKey(brw,{|b,k|appkey_diff(b,k,@mode)})

    brwCurrent(brw,ascan({"dif","old","new"},mode))

    brwShow(brw)
    brwLoop(brw)
end
    
    restscreen(,,,,scrn)
    setcursor(crs)

    return .t.



********************************************************************************************
static function appkey_diff(b,k,mode)
    if( k==K_ESC )
        mode:=NIL //kilép a brwLoop körüli ciklusból
        return .f.
    end


********************************************************************************************
static function diffcolor(x)
    if( "---"==x[1..3] )
        return {5}
    elseif( "+++"==x[1..3] )
        return {5}
    elseif( " "==x[1..1] )
        return {1}
    elseif( "-"==x[1..1] )
        return {3}
    elseif( "+"==x[1..1] )
        return {4}
    elseif( "@@"==x[1..2] )
        return {6}
    end
    return {5} //kiemelt fehér


********************************************************************************************


