
#include "inkey.ch"


********************************************************************************************
#define FETCH_VIEW  "View fetch status do merge/rebase"
#define FETCH_ALL   "Fetch from all remotes"

********************************************************************************************
function fetchmenu(brw,fetchmenu)
local rl,line
    asize(fetchmenu,0)

    aadd(fetchmenu,{line:=FETCH_VIEW,mkblock_fetch(brw,line)})
    aadd(fetchmenu,{line:=FETCH_ALL,mkblock_fetch(brw,line)})

    rl:=read_output_of("git remote")
    while( NIL!=(line:=rl:readline) )
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(fetchmenu,{line+" (fetch from this branch)",mkblock_fetch(brw,line)})
    end
    rl:close

    return fetchmenu


static function mkblock_fetch(brw,remote)
    return {||fetch(brw,remote)}


********************************************************************************************
static function fetch(brw,remote)

local cmd
local result:=""
local zframe,zbrowse
local ms,info,n

    if( remote==FETCH_VIEW )
        cmd:=FETCH_VIEW    
    elseif( remote==FETCH_ALL )
        cmd:="git fetch --all --prune"
        result:=output_of(cmd)
    else
        cmd:="git fetch "+remote
        result:=output_of(cmd)
    end

    //egy kis plusz infó    
    ms:=merge_status() //{{branch1,base1,tip1},{branch2,base2,tip2}, ... }
    info:=chr(10)
    for n:=1 to len(ms)
        if(ms[n][2]==ms[n][3])
            info+=" "
        else
            info+="!"
        end
        
        info+=ms[n][1]::padr(24)
        info+=ms[n][2]::padr(10)+" "
        info+=ms[n][3]::padr(10)+" "
        info+=chr(10)
    next
    result+=info
    
    zbrowse:=zbrowseNew(result)
    zbrowse:header1:=brwMenuname(brw)
    zbrowse:header2:=cmd + "  (F1,CTRL_D,CTRL_M,CTRL_R)"
    zbrowse:add_shortcut(K_F1,{|b|b:help},"Help")
    zbrowse:add_shortcut(K_CTRL_D,{|b|diff(b)},"Diff")
    zbrowse:add_shortcut(K_CTRL_M,{|b|merge(b)},"Merge")
    zbrowse:add_shortcut(K_CTRL_R,{|b|rebase(b)},"Rebase")

    zframe:=zframeNew()
    zframe:set(zbrowse)
    zframe:loop

    break("X") //kilép brwLoop-ból
    //Pulldown menü blokkjának return értékével 
    //nem lehet szabályozni a brwLoopból való kilépést.
    //Ha a visszatérési érték szám, akkor a menü
    //lenyitott állapotban marad, és a return érték
    //szerinti sor lesz benne kiválasztva,
    //egyébként becsukódik.



********************************************************************************************
static function diff(zb)

local screen,cr,cc
local t,l,b,r //NIL
local brname

    brname:=zb:seltext::alltrim
    while( "  "$brname )
        brname::=strtran("  "," ")
    end
    brname::=split(" ")
    if( len(brname)!=3 )
        return NIL
    end 
    if( brname[1][1]=="!" )
        brname[1]::=substr(2)
    end
    if( name_to_commitid(brname[1]) != brname[3]  )
        return NIL
    end
    brname:=brname[1]   //ellenőrzött branch name
    
    cr:=row()
    cc:=col()
    screen:=savescreen(t,l,b,r)
    
    run( "gitview.exe "+brname ) //a HEAD-del lesz a diff

    restscreen(t,l,b,r,screen)
    setpos(cr,cc) //nem szabad változnia!
    
    //Há ez mér pont itt van?
    //Itt vannak felsorolva könnyen kiválasztható helyzetben
    //a branchek, másrészt az is indokolt, ha a merge/rebase
    //előtt valaki vizsgálni óhajtja a várható változásokat.


********************************************************************************************
static function merge(zb)

local br,cmd,result,zbrowse

    br:=zb:seltext::alltrim::split(" ")
    if( empty(br) .or. br[1][1]!="!" )
        warnsel()
        return NIL
    end

    br:=br[1][2..]
    cmd:="git merge "+br
    result:=output_of(cmd)
    zbrowse:=zbrowseNew(result)
    zbrowse:header1:=branch_state_menuname()
    zbrowse:header2:=cmd
    zb:header1:=zbrowse:header1
    zb:topush:=zbrowse

    //kéne post-merge hook, de nincs
    run("filetime-restore.exe")

    return K_ESC



********************************************************************************************
static function rebase(zb)

local br,cmd,result,zbrowse

    br:=zb:seltext::alltrim::split(" ")
    if( empty(br) .or. br[1][1]!="!" )
        warnsel()
        return NIL
    end

    br:=br[1][2..]
    cmd:="git rebase "+br
    result:=output_of(cmd)
    zbrowse:=zbrowseNew(result)
    zbrowse:header1:=branch_state_menuname()
    zbrowse:header2:=cmd
    zb:header1:=zbrowse:header1
    zb:topush:=zbrowse

    run("filetime-restore.exe")

    return K_ESC
    

********************************************************************************************
static function warnsel()
    alert( "Branches marked with '!' can only be merged")


********************************************************************************************
