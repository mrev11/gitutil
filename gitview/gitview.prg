
#include "inkey.ch"

static context:="3" //a változások körül megjelenített sorok száma


static arg_commit1:="--staged"
static arg_commit2:="HEAD"
static descendant:=.t.
static menutitle

********************************************************************************************
function main()

local brw,sort:={}
local changes:={}
local rl,line,n
local current
local branches
local gitcmd

    change_to_gitdir()
    parseargs()
    branches:=list_of_branches(@current)
    
    menutitle:="["+current+": "
    if( arg_commit1=="--staged" )
        menutitle+="HEAD<-NEXT"
    else
        menutitle+=arg_commit1
        if( descendant )
            menutitle+="<-"
        else
            menutitle+="<>"
        end
        menutitle+=arg_commit2
    end
    menutitle+="]"
    

    setcursor(0)
    
    
    gitcmd:="git diff --name-status"
    gitcmd+=" "+arg_commit1
    gitcmd+=" "+arg_commit2

    rl:=read_output_of(gitcmd)
    while( (line:=rl:readline)!=NIL )
        if(debug())
            ?? line
        end
        line::=bin2str
        //line::=strtran(chr(9),"")
        line::=strtran(chr(10),"")
        //line::=alltrim
        changes::aadd(line::split(chr(9)))
    end
    rl:close
    
    if( empty(changes) )
        alert("No (staged) changes - quit.")
        quit
    end
    
    //? changes
    
    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwMenuName(brw,menutitle)
    brwArray(brw,changes)
    brwColumn(brw,"Stat",brwAblock(brw,1),replicate("X",8))
    brwColumn(brw,"File",brwAblock(brw,2),replicate("X",maxcol()-13))

    brwMenu(brw,"Diff","View changes of highlighted file",{||view_diff(changes[brwArrayPos(brw)][2])})
    brwMenu(brw,"Sort","Sort file in status or name order",sort)
    aadd(sort,{"By name",{|b|sortbyname(b)}})
    aadd(sort,{"By status",{|b|sortbystatus(b)}})

    brw:colorspec:="w/n,n/w,r+/n,g+/n,w+/n,rg+/n"
    //              1   2   3    4    5    6
    brw:getcolumn(1):colorblock:={|x|statcolor(x)}
    sortbystatus(brw)
    
    brwApplyKey(brw,{|b,k|appkey_main(b,k)})

    brw:gotop
    brwShow(brw)
    brwLoop(brw)


********************************************************************************************
static function appkey_main(b,k)
local arr,pos,fspec
    if( k==K_ESC )
        return .f.
    elseif( k==K_INS )
        arr:=brwArray(b)
        pos:=brwArrayPos(b)
        fspec:=arr[pos][2]
        view_blame(fspec)    
    end


********************************************************************************************
static function view_diff(fname)

local crs:=setcursor(1)
local scrn:=savescreen()
local rl,line,changes:={}
local brw,pos
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
        if(debug())
            ?? line
        end
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
static function statcolor(x)
    if( "A"$x )
        return {4}
    elseif( "D"$x )
        return {3}
    elseif( "M"$x )
        return {6}
    end
    return {1} //normál fehér



********************************************************************************************
static function sortbyname(b)    
local a:=brwArray(b)
    asort(a,,,{|x,y|x[2]<=y[2]})
    b:refreshall()
    
static function sortbystatus(b)    
local a:=brwArray(b)
    asort(a,,,{|x,y|if(x[1]==y[1],x[2]<=y[2],x[1]<=y[1])})
    b:refreshall()


********************************************************************************************
static function parseargs()

local argc:=argc()-1
local argv:=argv()

local id1
local id2
local base

    descendant:=.t.

    if( argc==0 )
        //default
        //összehasonlítva: HEAD<-NEXT(index) 

    elseif( argc>=1 )

        if(argc==1)
            aadd(argv,"HEAD")
        end
        //most len(argv)>=2

        id1:=name_to_commitid(argv[1])
        id2:=name_to_commitid(argv[2])
        base:=commitid_of_mergebase(argv[1],argv[2])
        
        if( base==id1 )
            //? "id2 későbbi mint id1"
            arg_commit1:=argv[1]
            arg_commit2:=argv[2]
        elseif( base==id2 ) 
            //? "id1 későbbi, mint id2"
            arg_commit1:=argv[2]
            arg_commit2:=argv[1]
        else
            //? "nincs sorrend"
            arg_commit1:=argv[1]
            arg_commit2:=argv[2]
            descendant:=.f.
        end
    end


********************************************************************************************
static function view_blame(fname)
local scrn:=savescreen()
local tmp:=tempfile()
    run( "git blame "+fname+" >"+tmp)
    run( "list.exe "+tmp)
    ferase(tmp)
    restscreen(,,,,scrn)
    return .t.


********************************************************************************************
















********************************************************************************************
