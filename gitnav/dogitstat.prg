
//eredetileg ez egy main volt

#include "box.ch"
#include "inkey.ch"


********************************************************************************************
function do_gitstat()

local brw,sort:={}
local changes:={}
local rl,line,n
local current
local branches
local gitcmd
local reread,prevpos
local blk1,blk2
local menutitle

local screen
local t,l,b,r
local cr,cc,cursta

    cr:=row()
    cc:=col()
    cursta:=setcursor()
    screen:=savescreen(t,l,b,r)

    branches:=list_of_branches(@current)

    setcursor(0)

    brw:=brwCreate(0,0,maxrow(),maxcol())
    menutitle:="["+current+"]"
    brwMenuName(brw,menutitle)
    brwArray(brw,changes:={{"",""}})

    blk1:={||column_stat(brwAblock(brw,1))}
    blk2:=brwAblock(brw,2)

    brwColumn(brw,"Stat",blk1,replicate("X",8))
    brwColumn(brw,"File",blk2,replicate("X",maxcol()-13))

    brwMenu(brw,"Diff","View diff between worktree and the last commit",{|b|diff(b)})
    brwMenu(brw,"AddOne","Stage the selected file/directory (add to commit)",{|b|addone(b,@reread)})
    brwMenu(brw,"ResetOne","Unstage the selected file/directory (eliminate from commit)",{|b|resetone(b,@reread)})
    brwMenu(brw,"AddAll","Stage the selected file/directory",{|b|addall(b,@reread)})
    brwMenu(brw,"ResetAll","Unstage the selected file/directory",{|b|resetall(b,@reread)})
    brwMenu(brw,"Checkout","Restore file from the last commit",{|b|checkout(b,@reread)})

    brw:colorspec:="w/n,n/w,r+/n,g+/n,w+/n,rg+/n,n/n"
    //              1   2   3    4    5    6     7
    brw:getcolumn(1):colorblock:={|x|statcolor(x)}
    
    brwApplyKey(brw,{|b,k|appkey_main(b,k)})

    gitcmd:="git status --short"

    brwShow(brw)                                       

    reread:=.t.
    while(reread)
        reread:=.f.                                           
    
        asize(changes,0)                                   
        aadd(changes,{"@@",replicate("-",brw:getcolumn(2):width) })

        rl:=read_output_of(gitcmd)                         
        while( (line:=rl:readline)!=NIL )                  
            line::=bin2str                                 
            line::=strtran(chr(9),"")                    
            line::=strtran(chr(10),"")                     
            changes::aadd( {line[1..2],line[4..]}  )             
        end                                                
        rl:close                                           
        if( empty(changes) )
            aadd(changes,{"",""})                               
        end                                                
        sortbystatus(brw)                                  

        if(prevpos!=NIL)
            brwArrayPos(brw,min(prevpos,len(brwArray(brw))))
        end                                                           

        brwMenuName(brw,branch_state_menuname(current))
        brwShow(brw)                                       
        brwLoop(brw)
        
        prevpos:=brwArrayPos(brw)                                       
    end                                                  

    restscreen(t,l,b,r,screen)
    setpos(cr,cc) //nem szabad változnia!
    setcursor(cursta)

********************************************************************************************
static function column_stat(blk)
local x:=eval(blk)
    if( x=="@@" )
        x:="  "
    end
    return x

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
static function diff(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local stat:=arr[pos][1]
local fspec:=arr[pos][2]

    if( "@@"$stat )
        //technikai sor
    elseif( "?"$stat )
        //untracked fi
        //nincs mivel összehasonlítani
    else
        view_diff(brw,"HEAD","")
    end
    return .t.


********************************************************************************************
static function addall(brw,reread)
    rundbg("git add --all")
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function addone(brw,reread)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]

    rundbg("git add "+fspec)
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
static function resetall(brw,reread)
    rundbg("git reset")
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function resetone(brw,reread)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]
    rundbg("git reset -q  -- "+fspec)
    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function checkout(brw,reread)

local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]::alltrim
local status:=arr[pos][1]
local result

    if( "@@"$status )
        //technikai sor
        return .t.

    elseif( right(fspec,1)==dirsep() )
        //directorykat nem checkoutolunk
        return .t.

    elseif( "R"$status )
        alert("RENAME")
        return .t. //ezzel mi legyen?

    elseif( "M"$status )
        //módosítások elveszhetnek
        if( 2>alert("After checking out changes will be lost",{"Escape","Continue"}))
            return .t.
        end
    end

    rundbg("git reset -q -- "+fspec)
    result:=output_of("git checkout -- "+fspec)
    if( "error:"$result .or. "fatal:"$result )
        zbrowseNew(result,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop
    end

    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function commit(brw,reread)
local result

    run("filetime-save.exe")
    rundbg("git add .FILETIME_$USER")
    run("firstpar.exe CHANGELOG_$USER >commit-message")
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
static function statcolor(x)
    if( "A"$x )
        return {4}
    elseif( "D"$x )
        return {3}
    elseif( "M"$x )
        return {6}
    elseif( "R"$x )
        return {6}
    elseif( "?"$x )
        return {3}
    end
    return {1} //normál fehér

********************************************************************************************
