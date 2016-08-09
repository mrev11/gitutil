
#include "inkey.ch"

********************************************************************************************
function branchmenu(branchmenu)
local rl,line
    asize(branchmenu,0)
    rl:=read_output_of("git branch")
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(branchmenu,{line,mkblock_setbranch(line)})
    end
    rl:close

    return branchmenu


static function mkblock_setbranch(b)
    return {||setbranch(b)}


********************************************************************************************
static function setbranch(b)

local brnew:=alltrim(b)
local brcur:=current_branch()
local br:={brcur,brnew}

    if( "*"$brnew )
        //ok
        break("X") //kilép brwLoop-ból
    end
    
    toggle(NIL,br)

    break("X") //kilép brwLoop-ból
    
    //Pulldown menü blokkjának return értékével 
    //nem lehet szabályozni a brwLoopból való kilépést.
    //Ha a visszatérési érték szám, akkor a menü
    //lenyitott állapotban marad, és a return érték
    //szerinti sor lesz benne kiválasztva,
    //egyébként becsukódik.


********************************************************************************************
static function toggle(zb,br)

local cmd,result
local zframe,zbrowse
local switched:="Switched to branch 'BRANCH'"
local x

    x:=br[1]
    br[1]:=br[2]
    br[2]:=x
    switched::=strtran("BRANCH",br[1])

    cmd:="git checkout "+br[1]
    result:=output_of(cmd)

    zbrowse:=zbrowseNew(result)
    zbrowse:colorblock:={|x|color(x)}
    zbrowse:header1:=cmd

    if( !switched$result )
        zbrowse:header2:="Failed"
        zbrowse:color2:="r+/n"

    else
        zbrowse:header2:="Switched"
        zbrowse:color2:="w+/n"

        zbrowse:add_shortcut(K_F1,{|zb|zb:help},"Help")
        zbrowse:add_shortcut(K_TAB,{|zb|toggle(zb,br)},"Toggle")
        zbrowse:add_shortcut(K_CTRL_D,{|zb|diff(zb)},"Diff")
    end
    
    if( zb==NIL )
        zframe:=zframeNew()
        zframe:set(zbrowse)
        zframe:loop
    else
        zb:toset(zbrowse)
        return K_ESC
    end


********************************************************************************************
static function diff(zb)
local sel:=zb:seltext::alltrim
local code:=sel[1..4]::rtrim
local fspec

    //[A   filespec...]
    //[M   filespec...]
    //[D   filespec...]

    if( code$"AMD" )
        fspec:=sel[5..]
        view_diff({"HEAD"},{fspec})
    end


********************************************************************************************
static function color(sel)
local code:=sel[1..4]::rtrim

    //[A   filespec...]
    //[M   filespec...]
    //[D   filespec...]

    if( code=="A" )
        return "g+/n"
    elseif( code=="M" )
        return "gr+/n"
    elseif( code=="D" )
        return "r+/n"
    else
        return "w/n"
    end

********************************************************************************************

#ifdef NOTDEFINED
  A korábbi koncepció az volt,
  hogy csak commitolt állapotban
  engedtük meg a branch váltást


static function old__setbranch(b)
    if( !repo_clean() )
        alert_if_not_committed()
    else
        b::=strtran("*","")
        rundbg("git checkout -f "+b)      //force nélkül a módosításokat nem írja felül
        rundbg("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
        link_local()
        break("X") //kilép brwLoop-ból
    end
    
    //Pulldown menü blokkjának return értékével 
    //nem lehet szabályozni a brwLoopból való kilépést.
    //Ha a visszatérési érték szám, akkor a menü
    //lenyitott állapotban marad, és a return érték
    //szerinti sor lesz benne kiválasztva,
    //egyébként becsukódik.

#endif


********************************************************************************************

