
#include "inkey.ch"

static basedata


**************************************************************************************
static class zpbrowse(zbrowse)
    method  initialize
    attrib  path


**************************************************************************************
static function zpbrowse.initialize(this,path,t,l,b,r)
local txt
    this:path:=path
    txt:=dirdata(path)
    this:(zbrowse)initialize(txt,t,l,b,r)
    return this


**************************************************************************************
static function dirdata(path:="")
local dirs:={}
local fils:={}
local n,line,pos:=9999,prev
local lenpath:=len(path)
local dirdata 

    for n:=1 to len(basedata)
        line:=basedata[n]
        if( line!=path )
            //path hosszában eltér
        elseif( left(line,pos)==prev )
            //már bevett directory
        elseif( 0!=(pos:=at(dirsep(),line,lenpath+1)) )
            prev:=line[1..pos]
            aadd(dirs,prev[lenpath+1..])
        else
            aadd(fils,line[lenpath+1..])
        end
    next
    
    dirdata:=""
    for n:=1 to len(dirs)
        dirdata+=dirs[n]+chr(10)
    next
    for n:=1 to len(fils)
        dirdata+=fils[n]+chr(10)
    next
    return dirdata



**************************************************************************************
static function init_basedata(commit)
local n
    basedata:=output_of( "git ls-tree --name-only -r "+commit )
    basedata::=split(chr(10))
    for n:=1 to len(basedata)
        if( basedata[n]::left(1)=='"' )
            basedata[n]:=basedata[n][2..len(basedata)-1]
        end
    next


**************************************************************************************
function browse_commit(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=read_commit_header(commit)
local zframe,zbrowse

    init_basedata(commit)

    zbrowse:=zpbrowseNew("") //gyökér
    zbrowse:header1:=head[1]
    zbrowse:header2:=head[3]
    zbrowse:add_shortcut(K_F1,{|b|b:help},"Help")
    zbrowse:add_shortcut(K_ENTER,{|zb|view_item(zb,commit)},"View")
    zbrowse:colorblock:={|x|color(x)}

    zframe:=zframeNew()
    zframe:set(zbrowse)
    zframe:loop

    return .t.


**************************************************************************************
static function color(x)
    if( right(x,1)=="/" )
        return "rg+/n"
    else
        return "bg+/n"
    end
    return "w/n"


**************************************************************************************
static function view_item(zbrowse,commit)
local fname:=zbrowse:seltext::alltrim
    if( right(fname,1)==dirsep() )   
        return view_dir(zbrowse,commit)
    else
        return view_file(zbrowse,commit)
    end

**************************************************************************************
static function view_dir(zbrowse,commit)
local dname:=zbrowse:seltext::alltrim
local zpbrowse:=zpbrowseNew(zbrowse:path+dname)
    zpbrowse:shortcut:=zbrowse:shortcut
    zpbrowse:header1:=zpbrowse:path
    zpbrowse:header2:=zbrowse:header2
    zpbrowse:colorblock:=zbrowse:colorblock
    zbrowse:topush(zpbrowse)
    return K_ESC


**************************************************************************************
static function view_file(zbrowse,commit)
local zb
local fname:=zbrowse:seltext::alltrim

    if(empty(fname))
        //kihagyjuk a dirlist-ek végén levő üres sort,
        //marad a zbrowse:loop-ban, nem csinál semmit 
        return NIL
    end
    fname:=zbrowse:path+fname
    zb:=zbrowseNew(output_of("git show "+commit+":"+fn_escape(fname)))
    
    zb:add_shortcut(K_F1,{|b|b:help},"Help")
    zb:add_shortcut(K_CTRL_B,{|z|shortcut_ctrl_b(z)},"Toggle blame")

    zb:header1:=fname
    zb:color1:="gb+/n"
    zb:header2:=zbrowse:header2
    zbrowse:topush(zb)
    return K_ESC

static function shortcut_ctrl_b(zb)
    zb:topush:=view_blame(zb)
    return K_ESC

**************************************************************************************
static function view_blame(zbrowse,commit)
local fname:=zbrowse:header1
local zb:=zbrowseNew(output_of("git blame "+fn_escape(fname)))
    zb:header1:=fname
    zb:color1:="gb+/n"
    zb:header2:=zbrowse:header2
    zb:add_shortcut(K_F1,{|b|b:help},"Help")
    zb:add_shortcut(K_CTRL_B,{||K_ESC},"Toggle blame")
    return zb


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


