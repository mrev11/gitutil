
#include "inkey.ch"


#ifdef NOTDEFINED
így néz ki az ls-tree kimenete
a hashek után eredetileg tab van
a hasheket célszerűen rövidítjük

100644 blob 9eabe5d0bc1e  .FILETIME_vermes
100644 blob ef5e97cf1789  .gitignore
100644 blob 2f3c48d2ccf4  CHANGELOG_vermes
100644 blob e62b1052c867  OLVASS
040000 tree 0b58652d6319  doc
040000 tree 74c7582e0ee2  filetime
040000 tree 4db0968390d4  firstpar
100755 blob a3cbf9f45a6f  gc
040000 tree 53f21427e9ef  gitdate
040000 tree 95226bcd658e  gitfind
040000 tree f10e6030d1a9  gitnav
100755 blob a7498d6cd0c4  gn
100755 blob bc50b4245c80  gr
100755 blob 0c8ac746f77b  gv
100755 blob 5ab53ed191bf  m
040000 tree 85628c9f8272  util
#endif

#define ABBREV      12                   // length of objid
#define NAMEPOS     (15+ABBREV)          // beginning of names
#define ISTREE(x)   x[8..11]=="tree"     // type tree (directory)
#define ISBLOB(x)   x[8..11]=="blob"     // type blob (fiel)
#define OBJID(x)    x[13..12+ABBREV]     // abbreviated hash
#define FNAME(x)    x[NAMEPOS..]         // file/directory name


**************************************************************************************
static class zdirbrowse(zbrowse)
    method  initialize
    attrib  path


**************************************************************************************
static function zdirbrowse.initialize(this,treeid,path,t,l,b,r)
    this:(zbrowse)initialize(dirdata(treeid),t,l,b,r)
    this:path:=path
    return this

**************************************************************************************
static function dirdata(treeid)

local dirs:={}
local fils:={}
local n,line
local basedata 
local dirdata 

    basedata:=output_of( "git ls-tree --abbrev="+ABBREV::str::alltrim+" "+treeid )
    basedata::=strtran(chr(9),"  ")
    basedata::=split(chr(10))

    for n:=1 to len(basedata)
        line:=basedata[n]
        if( line[NAMEPOS]=='"' )
            line::=stuff(NAMEPOS,1,"")
            line::=stuff(len(line),1,"")
        end
        if( ISTREE(line) )
            aadd(dirs,line)
        else
            aadd(fils,line)
        end
    next
    asort(fils,,,{|a,b|FNAME(a)<FNAME(b)})
    asort(dirs,,,{|a,b|FNAME(a)<FNAME(b)})
    
    dirdata:=""
    for n:=1 to len(dirs)
        dirdata+=dirs[n]+chr(10)
    next
    for n:=1 to len(fils)
        dirdata+=fils[n]+chr(10)
    next
    return dirdata


**************************************************************************************
function browse_commit(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=read_commit_header(commit)
local zframe,zbrowse

    zbrowse:=zdirbrowseNew(commit,"") //gyökér
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
    if( x[8..11]=="tree" )
        return "rg+/n"
    else
        return "bg+/n"
    end
    return "w/n"


**************************************************************************************
static function view_item(zbrowse,commit)
local line:=zbrowse:seltext::alltrim
    if( ISTREE(line) )
        return view_dir(zbrowse)
    else
        return view_file(zbrowse,commit)
    end

**************************************************************************************
static function view_dir(zbrowse)
local zdirbrowse
local line:=zbrowse:seltext::alltrim
local treeid:=OBJID(line)
local dname:=FNAME(line)

    if(empty(dname))
        return NIL
    end
    
    //alert("'"+treeid+"'")

    zdirbrowse:=zdirbrowseNew(treeid,zbrowse:path+dname+"/")
    zdirbrowse:shortcut:=zbrowse:shortcut
    zdirbrowse:header1:=zdirbrowse:path
    zdirbrowse:header2:=zbrowse:header2
    zdirbrowse:colorblock:=zbrowse:colorblock
    zbrowse:topush(zdirbrowse)
    return K_ESC


**************************************************************************************
static function view_file(zbrowse,commit)
local zb
local fname:=FNAME(zbrowse:seltext::alltrim)

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


