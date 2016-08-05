
#include "inkey.ch"


********************************************************************************************
#define FETCH_VIEW  "View fetch status do merge/rebase/push"
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
        aadd(fetchmenu,{line+" (fetch from this remote)",mkblock_fetch(brw,line)})
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
    zbrowse:header2:=cmd + "  (F1,CTRL_D,CTRL_M,CTRL_R,CTRL_P)"
    zbrowse:add_shortcut(K_F1,{|b|b:help},"Help")
    zbrowse:add_shortcut(K_CTRL_D,{|b|diff(b)},"Diff")
    zbrowse:add_shortcut(K_CTRL_M,{|b|merge(b)},"Merge")
    zbrowse:add_shortcut(K_CTRL_R,{|b|rebase(b)},"Rebase")
    zbrowse:add_shortcut(K_CTRL_P,{|b|push(b)},"Push")
    zbrowse:colorblock:={|zb|color(zb)}

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
static function color(x)  
    if(x::alltrim[1..1]=="!")
        return "r+/n"
    end
    return NIL

********************************************************************************************
static function diff(zb)

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
    
    do_gitview(brname)

    //Há ez mér pont itt van?
    //Itt vannak felsorolva könnyen kiválasztható helyzetben
    //a branchek, másrészt az is indokolt, ha a merge/rebase
    //előtt valaki vizsgálni óhajtja a várható változásokat.


********************************************************************************************
static function merge(zb)

local br,cmd,result,zbrowse

    br:=zb:seltext::alltrim::split(" ")
    if( empty(br) .or. br[1][1]!="!" )
        warnsel_merge()
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
        warnsel_rebase()
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
static function push(zb)

local sel,rem,cur,rbr
local cmd,result,zbrowse

    sel:=zb:seltext::alltrim::split(" ")
    if( empty(sel) )
        warnsel_push()
        return NIL
    end
    sel:=sel[1]::split("/") //{remote,branch}
    if(len(sel)!=2)
        warnsel_push()
        return NIL
    end

    rem:=sel[1]
    rbr:=sel[2]
    cur:=current_branch()
    
    if( !cur==rbr )
        if(2>alert("You are pushing '"+cur+"' to '"+rbr+"'",{"Escape","Continue"}))
            return NIL
        end
    end

    cmd:="git push "+rem+" "+cur+":"+rbr
    result:=output_of(cmd)

    zbrowse:=zbrowseNew(result)
    zbrowse:header1:=branch_state_menuname()
    zbrowse:header2:=cmd
    zb:header1:=zbrowse:header1
    zb:topush:=zbrowse

    return K_ESC





********************************************************************************************
static function warnsel_merge()
    alert( "Branches marked with '!' can only be merged")

static function warnsel_rebase()
    alert( "Branches marked with '!' can only be rebase with")

static function warnsel_push()
    alert( "You can push only to remote branches")


********************************************************************************************
