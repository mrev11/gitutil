
#include "inkey.ch"

static arg_commit1:="--staged"
static arg_commit2:="HEAD"
static descendant:=.t.
static menutitle
static commitmenu:=.f.

********************************************************************************************
function main()

local brw,sort:={}
local changes:={}
local rl,line,n
local current
local branches
local gitcmd
local reread,prevpos

    change_to_gitdir()
    parseargs()
    branches:=list_of_branches(@current)
    
    menutitle:="["+current+": "
    if( arg_commit1=="--staged" )
        menutitle+="HEAD<-NEXT"
        commitmenu:=.t.
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

    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwMenuName(brw,menutitle)
    brwArray(brw,changes:={{"",""}})
    brwColumn(brw,"Stat",brwAblock(brw,1),replicate("X",8))
    brwColumn(brw,"File",brwAblock(brw,2),replicate("X",maxcol()-13))

    if(commitmenu)
        brwMenu(brw,"Add","Add all changes to index",{||addall(brw,@reread)})
    end

    brwMenu(brw,"Diff","View changes of highlighted file",{||view_diff(brw,arg_commit1,arg_commit2)})

    if(commitmenu)
        brwMenu(brw,"Reset","Eliminate selected file form the next commit",{||resetone(brw,@reread)})
        brwMenu(brw,"Commit","Commit changes",{||commit(brw,@reread)})
    end

    //brwMenu(brw,"Sort","Sort file in status or name order",sort) //kell?
    //aadd(sort,{"By name",{|b|sortbyname(b)}})
    //aadd(sort,{"By status",{|b|sortbystatus(b)}})

    brw:colorspec:="w/n,n/w,r+/n,g+/n,w+/n,rg+/n"
    //              1   2   3    4    5    6
    brw:getcolumn(1):colorblock:={|x|statcolor(x)}
    
    brwApplyKey(brw,{|b,k|appkey_main(b,k)})

    gitcmd:="git diff --name-status"
    gitcmd+=" "+arg_commit1
    gitcmd+=" "+arg_commit2
    gitcmd+=" --" //egyezo branch- es fajlnev elkerulese

    brwShow(brw)                                       

    reread:=.t.
    while(reread)
        reread:=.f.                                           
                                                           
        asize(changes,0)                                   
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
            aadd(changes,{"",""})                               
            //alert("No (staged) changes - quit.")           
            //quit                                           
        end                                                
        sortbystatus(brw)                                  

        if(prevpos!=NIL)
            brwArrayPos(brw,min(prevpos,len(brwArray(brw))))
        end                                                           

        brwLoop(brw)
        
        prevpos:=brwArrayPos(brw)                                       
    end                                                  


********************************************************************************************
static function appkey_main(b,k)
local arr,pos
local fspec,ftext

    if( k==K_ESC )
        return .f.
    elseif( k==K_CTRL_B )
        arr:=brwArray(b)
        pos:=brwArrayPos(b)
        fspec:=arr[pos][2]
        ftext:=output_of("git blame "+fspec)
        zbrowseNew(ftext,b:ntop,b:nleft,b:nbottom,b:nright):loop
    end


********************************************************************************************
static function addall(brw,reread)
    run("git add --all")
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki

/*
local choice:=alert("reset",{"reread","esc"})
    if( choice==0 )
        return .t.   //semmi, folytat
    elseif( choice==1 )
        reread:=.t.  //uj brw array lesz
        return .f.   //jelenlegi brwloop-bol ki
    else 
        reread:=.f.
        return .f.   //brwloop-bol végleg ki
    end
*/

********************************************************************************************
static function resetone(brw,reread)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]
    run("git reset -- "+fspec)
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function commit(brw,reread)
local result
    //jó vóna ezeket betenni a pre-commit hook-ba
    //de a hook nem tudja módosítani a commit tartalmát

    run("filetime-save.exe")
    run("git add .FILETIME_$USER")
    run("firstpar.exe CHANGELOG_$USER >commit-message")

    //run("git commit -F commit-message")
    //mégse jó csak úgy elengedni a kimenetet,
    //mert a júzer nem fogja érteni, mi történt
    
    result:=output_of("git commit -F commit-message")
    zbrowseNew(result,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop
    

    reread:=.f.
    return .f.   //brwloop-bol végleg ki


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
        if( len(id1)!=40 )
            alert("WRONG ARGUMENT;;'"+argv[1]+"' does not identify a commit")
            quit
        end

        id2:=name_to_commitid(argv[2])
        if( len(id2)!=40 )
            alert("WRONG ARGUMENT;;'"+argv[2]+"' does not identify a commit")
            quit
        end

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
