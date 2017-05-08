
#include "inkey.ch"

static context:="3" //a változások körül megjelenített sorok száma


********************************************************************************************
function view_diff(commit,fspec) //({com1,com2,...},{fsp1,fsp2,...  })

local crs:=setcursor(1)
local cr:=row(),cc:=col()
local scrn:=savescreen()
local rl,line,changes:={}
local gitcmd:={}
local mode:="dif"
local brw,pos,n

while( mode!=NIL )

    changes:={}

    //a szóközt tartalmazó fájlnevek miatt
    //nem lehet a child-ban levő szóközöknél 
    //történő darabolásra hagyatkozni

    gitcmd:={}
    gitcmd::aadd("git")
    gitcmd::aadd("diff")

    // -w opcio
    // Ne nezze osszehasonlitaskor a whitespace-eket. 
    // Maskepp a crlf-es fajlok minden sorukban kulonboznek.
    // Uj neve "--ignore-all-spaces", a 2.7.4 nem fogadja el.
    // gitcmd::aadd("--ignore-all-spaces")
    gitcmd::aadd("-w")

    gitcmd::aadd("-U"+context)
    for n:=1 to len(commit)
        gitcmd::aadd(commit[n])
    next
    gitcmd::aadd("--")
    for n:=1 to len(fspec)
        gitcmd::aadd(fspec[n])
    next
    
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
    brwMenuName(brw,"["+fspec[1]+"]")
    brwArray(brw,changes)
    brwColumn(brw,"", brwAblock(brw,1),replicate("X",maxcol()-2))

    brwMenu(brw,"Diff","Diff mode" ,{||mode:="dif",.f.})
    brwMenu(brw,"Old","Old version",{||mode:="old",.f.})
    brwMenu(brw,"New","New version",{||mode:="new",.f.})
    brwMenu(brw,"Context-"+context,"Number of lines around changes",{||context::=getcontext,.f.})
    
    brw:colorspec:="w/n,n/w,,,,,,,,,,,r+/n,g+/n,w+/n,bg+/n"
    //              1   2             13   14   15   16

    brw:getcolumn(1):colorblock:={|x|diffcolor(x)}
    
    brw:headsep:="" //nincs oszlopnév!
    brw:cargo[12]:=.f.  //BR_HIGHLIGHT nincs rá API

    brwApplyKey(brw,{|b,k|appkey_diff(b,k,@mode)})

    brwCurrent(brw,ascan({"dif","old","new"},mode))

    brwShow(brw)
    brwLoop(brw)
end
    
    restscreen(,,,,scrn)
    setpos(cr,cc)
    setcursor(crs)


********************************************************************************************
static function appkey_diff(b,k,mode)
    if( k==K_ESC )
        mode:=NIL //kilép a brwLoop körüli ciklusból
        return .f.
    end


********************************************************************************************
static function diffcolor(x)
    if( "---"==x[1..3] )
        return {15}
    elseif( "+++"==x[1..3] )
        return {15}
    elseif( " "==x[1..1] )
        return {1}
    elseif( "-"==x[1..1] )
        return {13}
    elseif( "+"==x[1..1] )
        return {14}
    elseif( "@@"==x[1..2] )
        return {16}
    end
    return {15} //kiemelt fehér


********************************************************************************************


