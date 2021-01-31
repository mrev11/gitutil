

//eredetileg ez egy main volt

#include "inkey.ch"
#include "fileio.ch"

static arg_commit1:="--staged"
static arg_commit2:="HEAD"
static descendant:=.t.


********************************************************************************************
function do_gitview(*)

local menutitle
local commitmenu:=.f.
local rebasemenu:=.f.
local diffhelp:="of highlighted file"

local brw,sort:={}
local changes:={}
local rl,line,n
local current
local branches
local gitcmd
local reread,prevpos

local screen
local t,l,b,r
local cr,cc,cursta

    cr:=row()
    cc:=col()
    cursta:=setcursor()
    screen:=savescreen(t,l,b,r)

    parseargs(*)
    branches:=list_of_branches(@current)
    
    menutitle:="["+current+": "
    if( arg_commit1=="--staged" )
        menutitle+="HEAD<-NEXT"
        diffhelp:="between HEAD and index (next commit)"
        if( " rebasing "$current )
            rebasemenu:=.t.
        else
            commitmenu:=.t.
        end
    else
        menutitle+=arg_commit1
        if( descendant )
            menutitle+="<-"
        else
            menutitle+="<>"
        end
        menutitle+=arg_commit2
        diffhelp:="between "+arg_commit1+" and "+arg_commit2
    end
    menutitle+="]"

    setcursor(0)

    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwMenuName(brw,menutitle)
    brwArray(brw,changes:={{"",""}})
    brwColumn(brw,"Stat",brwAblock(brw,1),replicate("X",8))
    brwColumn(brw,"File",brwAblock(brw,2),replicate("X",maxcol()-13))

    if(commitmenu.or.rebasemenu)
        brwMenu(brw,"AddAll","Add all changes of all files/directories to the index (stage all)",{||addall(brw,@reread)})
    end

    brwMenu(brw,"Diff","View changes "+diffhelp,{|b|diff(b)})

    if(commitmenu)
        brwMenu(brw,"ResetOne","Eliminate selected file form the next commit (unstage one)",{||resetone(brw,@reread)})
        brwMenu(brw,"Commit","Commit changes",{||commit(brw,@reread)})
    end

    if(rebasemenu)
        brwMenu(brw,"Continue","Continue pending rebase",{||rebase_continue(brw,@reread)})
        brwMenu(brw,"Abort","Abort pending rebase",{||rebase_abort(brw,@reread)})
    end

    //brwMenu(brw,"Sort","Sort file in status or name order",sort) //kell?
    //aadd(sort,{"By name",{|b|sortbyname(b)}})
    //aadd(sort,{"By status",{|b|sortbystatus(b)}})

    brw:colorspec:="w/n,n/w,,,,,,,,,,,r+/n,g+/n,w+/n,rg+/n"
    //              1   2             13   14   15   16
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
        elseif(followed_file()!=NIL)
            namepos(brw,followed_file())
        end                                                           

        brwLoop(brw)
        
        prevpos:=brwArrayPos(brw)                                       
    end                                                  

    restscreen(t,l,b,r,screen)
    setpos(cr,cc) //nem szabad változnia!
    setcursor(cursta)


********************************************************************************************
static function appkey_main(b,k)
local arr,pos
local fspec,ftext

    if( k==K_ESC )
        return .f.
    elseif( k==K_ALT_B )
        arr:=brwArray(b)
        pos:=brwArrayPos(b)
        fspec:=arr[pos][2]
        ftext:=output_of("git blame "+fn_escape(fspec))
        zbrowseNew(ftext,b:ntop,b:nleft,b:nbottom,b:nright):loop
    end



********************************************************************************************
static function diff(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]
    view_diff( {arg_commit1,arg_commit2},{fspec} )
    return .t.


********************************************************************************************
static function addall(brw,reread)
    rundbg("git add --all")
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
    rundbg("git reset -- "+fn_escape(fspec))
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function commit(brw,reread)
local result
local ftsave

    //jó volna ezeket betenni a pre-commit hook-ba
    //de a hook nem tudja módosítani a commit tartalmát

    ftsave:=output_of("filetime-save.exe")
    rundbg("git add .FILETIME_$USER"::strtran("$USER",username()))
    run("firstpar.exe CHANGELOG_$USER >commit-message"::strtran("$USER",username()))
    result:=output_of("git commit -F commit-message")
    commitlog(result)
    zbrowseNew(result+ftsave,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop

    reread:=.f.
    return .f.   //brwloop-bol végleg ki


********************************************************************************************
static function rebase_continue(brw,reread)
local result
    result:=output_of("git rebase --continue")
    zbrowseNew(result,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop
    reread:=.f.
    return .f.   //brwloop-bol végleg ki


********************************************************************************************
static function rebase_abort(brw,reread)
local result
    result:=output_of("git rebase --abort")
    //zbrowseNew(result,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop
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
static function parseargs(*)

local argv:={*}
local argc:=len(argv)

local id1
local id2
local base

    //static változók
    //a "függvényesítés" miatt mindig 
    //meg kell adni a kezdőértékeket 
    arg_commit1:="--staged"
    arg_commit2:="HEAD"
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
        return {14}
    elseif( "D"$x )
        return {13}
    elseif( "M"$x )
        return {16}
    elseif( "R"$x )
        return {16}
    end
    return {1} //normál fehér


********************************************************************************************
static function commitlog(result)
local pos:=at(chr(10),result)
local fd:=fopen(".git/local/log-commit",FO_CREATE+FO_APPEND+FO_READWRITE)
    if( pos>0 )
        result::=left(pos)
    elseif(!empty(result))
        result+=chr(10)
    end
    if( fd>=0 )
        fwrite(fd,result)
        fclose(fd)
    end


********************************************************************************************
static function namepos(brw,name)
local arr:=brwArray(brw)
local pos:=ascan(arr,{|x|name==x[2]})
    if( pos==0 )
        name::=fnameext
        pos:=ascan(arr,{|x|name==x[2]::fnameext})
    end
    pos::=max(1)
    brwArrayPos(brw,pos)
    brw:rowpos:=min(pos,int((brw:nbottom-brw:ntop)/2))


********************************************************************************************
function followed_file(file)
static x:=NIL
    if( file!=NIL )
        x:=file
    end
    return x


********************************************************************************************





