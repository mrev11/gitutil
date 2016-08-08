
#include "inkey.ch"


********************************************************************************************
#define FETCH_VIEW  "View fetch status do merge/rebase/push"
#define FETCH_ALL   "Fetch from all remotes"

********************************************************************************************
function fetchmenu(fetchmenu)
local rl,line
    asize(fetchmenu,0)

    aadd(fetchmenu,{line:=FETCH_VIEW,mkblock_fetch(line)})
    aadd(fetchmenu,{line:=FETCH_ALL,mkblock_fetch(line)})

    rl:=read_output_of("git remote")
    while( NIL!=(line:=rl:readline) )
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(fetchmenu,{line+" (fetch from this remote)",mkblock_fetch(line)})
    end
    rl:close

    return fetchmenu


static function mkblock_fetch(remote)
    return {||fetch_status_loop(remote)}


********************************************************************************************
static function fetch_status_loop(remote)
local zframe,zbrowse

    zbrowse:=zbrowseNew("REMOTE="+remote)
    zbrowse:add_shortcut(K_CTRL_F,{|zb|fetch(zb)})
    keyboard chr(K_CTRL_F)
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
static function zbstatus(zb,cmd,result)

local zbrowse
local line,info,op,n
local head:=name_to_commitid("HEAD")
local ms:=merge_status() //{{branch1,base1,tip1},{branch2,base2,tip2}, ... }
local status:=chr(10)

#define RM_F    op+=if("/"$ms[n][1],"[F]","[ ]")    //fetch
#define OP_D    op+="[D]"                           //diff
#define OP_M    op+="[M]"                           //merge
#define OP_R    op+="[R]"                           //rebase
#define RM_P    op+=if("/"$ms[n][1],"[P]","[ ]")    //push
#define XX_D    op+="[ ]"                           //diff
#define XX_M    op+="[ ]"                           //merge
#define XX_R    op+="[ ]"                           //rebase
#define XX_P    op+="[ ]"                           //rebase

    for n:=1 to len(ms)
        line:=" "
        line+=ms[n][1]::padr(24)     //branch name
        line+=ms[n][2]::padr(10)+" " //merge-base
        line+=ms[n][3]::padr(10)+" " //tip
        
        op:=" "

        if( head==ms[n][3] )
            info:=" HEAD"

            RM_F
            XX_D
            XX_M 
            XX_R 
            XX_P 
        
        elseif( ms[n][2]==ms[n][3] )
            //le van maradva
            info:=" behind with "+number_of_commits_between(ms[n][3],head)::str::alltrim+" commit(s)"

            RM_F
            OP_D
            XX_M 
            XX_R 
            RM_P 

        elseif( head==ms[n][2]  )
            //előrébb van
            info:=" ahead by "+number_of_commits_between(head,ms[n][3])::str::alltrim+" commit(s)"

            RM_F
            OP_D
            OP_M 
            OP_R 
            XX_P 

        else
            //el van ágazva
            info:=" forked by "+number_of_commits_between(ms[n][2],ms[n][3])::str::alltrim+" commit(s)"

            RM_F
            OP_D
            OP_M 
            OP_R 
            RM_P
        end
        line+=op::padr(17)+info::padr(28)

        status+=line+chr(10)
    next
    
    if(!empty(result))
        status+=chr(10)
        status+=result
    end
    
    zbrowse:=zbrowseNew(status)
    zbrowse:header1:=branch_state_menuname()
    zbrowse:header2:=cmd+"  (F1,CTRL_F,CTRL_D,CTRL_M,CTRL_R,CTRL_P)"
    zbrowse:add_shortcut(K_F1,{|b|b:help},"Help")
    zbrowse:add_shortcut(K_CTRL_F,{|b|fetch(b)},"Fetch")
    zbrowse:add_shortcut(K_CTRL_D,{|b|diff(b)},"Diff")
    zbrowse:add_shortcut(K_CTRL_M,{|b|merge(b)},"Merge")
    zbrowse:add_shortcut(K_CTRL_R,{|b|rebase(b)},"Rebase")
    zbrowse:add_shortcut(K_CTRL_P,{|b|push(b)},"Push")
    zbrowse:colorblock:={|zb|color(zb)}

    //maradjon helyben a sáv
    zbrowse:sftrow:=zb:sftrow
    zbrowse:winrow:=zb:winrow
    
    return zbrowse


********************************************************************************************
static function fetch(zb)

local cmd
local result:=""
local zbrowse
local remote

local brname

    if( zb:atxt[1][1..7]=="REMOTE=" )
        remote:=zb:atxt[1][8..]
        if( remote==FETCH_VIEW )
            cmd:=FETCH_VIEW    
        elseif( remote==FETCH_ALL )
            cmd:="git fetch --all"
            result:=output_of(cmd)
        else
            cmd:="git fetch "+remote
            result:=output_of(cmd)
        end
        
    else
        //zb-ből kiolvassuk, hogy mit kell fetchelni
        //cmd: a fetch parancs
        //result: a fetch eredménye

        brname:=brname(zb)

        brname::=split("/")
        if( len(brname)!=2 )
            alert( "You can fetch only from remote branches")
            return NIL
        end
        
        cmd:="git fetch "+brname[1]+" "+brname[2]
        result:=output_of(cmd)
    end
    
    zb:toset:=zbstatus(zb,cmd,result) //utolsó parancs és annak eredménye
    return K_ESC


********************************************************************************************
static function merge(zb)

local brname
local cmd,result,zbrowse

    brname:=brname(zb)

    if( !"[M]"$zb:seltext )
        alert( "Cannot merge with this branch")
        return NIL
    end

    cmd:="git merge "+brname
    result:=output_of(cmd)
    //kéne post-merge hook, de nincs
    run("filetime-restore.exe")

    zb:toset:=zbstatus(zb,cmd,result) //utolsó parancs és annak eredménye
    return K_ESC


********************************************************************************************
static function rebase(zb)

local brname
local cmd,result,zbrowse

    brname:=brname(zb)

    if( !"[R]"$zb:seltext )
        alert( "Cannot rebase with this branch")
        return NIL
    end

    cmd:="git rebase "+brname
    result:=output_of(cmd)
    run("filetime-restore.exe")

    zb:toset:=zbstatus(zb,cmd,result) //utolsó parancs és annak eredménye
    return K_ESC
    

********************************************************************************************
static function push(zb)

local rem,cur,rbr
local brname
local cmd,result,zbrowse

    brname:=brname(zb)

    brname::=split("/")
    if( len(brname)!=2 )
        alert( "You can push only to remote branches")
        return NIL
    end

    if( !"[P]"$zb:seltext )
        alert( "Nothing to push")
        return NIL
    end

    rem:=brname[1]
    rbr:=brname[2]
    cur:=current_branch()
    
    if( !cur==rbr )
        if(2>alert("You are pushing '"+cur+"' to '"+rbr+"'",{"Escape","Continue"}))
            return NIL
        end
    end

    cmd:="git push "+rem+" "+cur+":"+rbr
    result:=output_of(cmd)

    zb:toset:=zbstatus(zb,cmd,result) //utolsó parancs és annak eredménye
    return K_ESC
    

********************************************************************************************
static function diff(zb)
local brname:=brname(zb)
    if(brname!=NIL)
        do_gitview(brname)
    end

    //Itt vannak felsorolva könnyen kiválasztható helyzetben
    //a branchek, másrészt az is indokolt, ha a merge/rebase
    //előtt valaki vizsgálni óhajtja a várható változásokat.



********************************************************************************************
static function color(x)  
    if( "[M]"$x .or. "[R]"$x  )
        return "gb+/n"
    end
    return NIL


********************************************************************************************
static function number_of_commits_between(c1,c2)
local cmd:='git log --pretty="%h" '+c1+".."+c2
local rl:=read_output_of(cmd),line,n:=0
    while( NIL!=(line:=rl:readline) )
        n++
    end
    rl:close
    return n
    

********************************************************************************************
static function brname(zb)
local line
    line:=zb:seltext::alltrim
    while( "  "$line )
        line::=strtran("  "," ")
    end
    line::=split(" ")
    if( len(line)<3 )
        return NIL
    end
    if( name_to_commitid(line[1]) != line[3]  )
        return NIL
    end
    return line[1]  //ellenőrzött branch name


********************************************************************************************
