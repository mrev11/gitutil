
#include "inkey.ch"


**************************************************************************************
function browse_commit(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    browse(commit)
    return .t.


**************************************************************************************
static function browse(commit)

local head:=read_commit_header(commit)
local data:=output_of( "git ls-tree --name-only -r "+commit )
local zframe:=zframeNew()
local zbrowse:=zbrowseNew(data)

    zbrowse:header1:=head[1]
    zbrowse:header2:=head[3]
    zbrowse:add_shortcut(K_ENTER,{||view_file(zbrowse,commit)})
    zframe:set(zbrowse)
    zframe:loop


**************************************************************************************
static function view_file(zbrowse,commit)

local zbp  //plain
local zbb  //blame
local fname:=zbrowse:seltext

    zbp:=zbrowseNew(output_of("git show "+commit+":"+fname))
    zbb:=zbrowseNew(output_of("git blame "+fname))
    
    zbb:add_shortcut(K_CTRL_B, {|z|shortcut_ctrl_b(z,zbb,zbp)})  //ugyanaz
    zbp:add_shortcut(K_CTRL_B, {|z|shortcut_ctrl_b(z,zbb,zbp)})  //ugyanaz

    zbp:header1:=zbb:header1:=fname
    zbp:color1:=zbb:color1:="gb+/n"
    zbp:header2:=zbb:header2:=zbrowse:header2

    zbrowse:topush(zbp)
    return K_ESC
    

**************************************************************************************
static function shortcut_ctrl_b(zb,zbb,zbp)
    zb:toset:=if(zb==zbb,zbp,zbb)  //toggle
    return K_ESC


**************************************************************************************
static function read_commit_header(commit)
local gitcmd:="git log --date=iso-local --stat --summary "+commit+"^.."+commit
local rl,line,arr:={}
    rl:=read_output_of(gitcmd)
    while( NIL!=(line:=rl:readline) .and. len(arr)<3 )
        //?? line
        aadd(arr,line::bin2str::strtran(chr(10),""))
    end
    rl:close
    return arr //{id,author,date}


**************************************************************************************


