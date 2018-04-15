
#include "inkey.ch"
#include "directry.ch"

// browseolja a commitokat
// de csak azokat, amik a megadott fajlt modositottak


********************************************************************************************
function main()

local logcmd
local pretty:=config_value_of("format.pretty")
local dtform:=config_value_of("log.date")
local number:="-32"
local follow

local brw,com:={{"","",""}},n
local rl,line,pos


    //szóközök miatt a {} paraméterezés kell
    logcmd:={}
    logcmd::aadd("git")
    logcmd::aadd("log")

    for n:=1 to argc()-1
        if( argv(n)[1]=="-" .and. argv(n)[2..]::val>0 )
            number:=argv(n) //string
        elseif( argv(n)[1..9]=="--pretty=" )
            pretty:=argv(n)[10..]
        elseif( argv(n)[1..7]=="--date=" )
            dtform:=argv(n)[8..]
        else
            follow:=argv(n)
        end
    next
    
    if( follow==NIL )
        ? "Usage: gitfollow <filename>"
        ?
        quit
    end

    if( pretty::empty )
        pretty:='%h %s'
    end
    if( dtform::empty )
        dtform:="short"
    end

    //kell-e ezt idezni, ha szokozt tartalmaz?
    #ifdef _WINDOWS_
      //Windowson idezni kell
      logcmd::aadd('"--pretty='+pretty+'"')
    #else
      //Linuxon nem szabad idezni
      logcmd::aadd('--pretty='+pretty)
    #endif
    logcmd::aadd("--date="+dtform)
    logcmd::aadd(number)

    logcmd::aadd("--follow")
    logcmd::aadd(follow)

    setcursor(0)

    
    brw:=brwCreate(0,0,maxrow(),maxcol())

    brwArray(brw,com)

    brwColumn(brw,"Commit",brwAblock(brw,2),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,3),replicate("X",maxcol()-16))

    brwMenu(brw,"DiffPrev","View changes caused by the selected commit",{||diffprev(brw)})
    brwMenu(brw,"DiffHead","View changes between selected commit and HEAD",{||diffhead(brw)})
    brwMenu(brw,"Browse","Browse files of selected commit",{||browse_commit(brw)})

    brwApplyKey(brw,{|b,k|appkey(b,k)})

    brwMenuName(brw,"[follow: "+follow+"]")

    brw:colorspec:="w/n,n/w,,,,,,,,,,,w+/n,rg+/n"
    brw:getcolumn(1):colorblock:={|x|{14}}


    com::asize(0) //commitok
    rl:=read_output_of(logcmd)
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        if( at("fatal:",line)==1 )
            ? line
            quit
        end
        line::=strtran(chr(10),"")
        pos:=at(" ",line)
        aadd(com,{"",line[1..pos-1],line[pos+1..]})
    end
    rl:close
    
    //for n:=1 to len(com)
    //    ? n, com[n][2], com[n][3]::left(50)
    //next

    if(empty(com))
        ? "No commit found"
        ?
        quit
    end

    change_to_gitdir()
    
    brwShow(brw)
    brwLoop(brw)
    brwHide(brw)


********************************************************************************************
static function appkey(b,k)
    if( k==K_ESC )
        quit
    elseif( k==K_INS )
        viewcommit(b)
    end


********************************************************************************************
static function diffprev(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    if( pos<len(arr) )
        do_gitview(commit+"^", commit)
    end
    return .t.


********************************************************************************************
static function diffhead(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=arr[1][2]
    //if( pos==1 )
    //    //HEAD-et a HEAD-del diffelni értelmetlen
    //else
        do_gitview(commit,"HEAD")
    //end
    return .t.


********************************************************************************************
