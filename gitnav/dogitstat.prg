
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
            changes::aadd( {line[1..2],line[4..]::unquote}  )             
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
        ftext:=output_of("git blame "+fn_escape(fspec))
        zbrowseNew(ftext,b:ntop,b:nleft,b:nbottom,b:nright):loop
    end


********************************************************************************************
static function diff(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local status:=arr[pos][1]
local fspec:=arr[pos][2]

    if( status=="@@" )
        //technikai sor

    elseif( "R"$status )

        //átnevezés: src -> dst
        //az src diffjét mutatjuk

        fspec::=replace_name
        if( valtype(fspec)=="A" )
            fspec:=fspec[1]
            view_diff({"HEAD"},{fspec})
        else
            return .t. //??? 
        end

    elseif( status=="??" )
        //untracked file
        view_diff({"--no-index"},{fspec,"/dev/null"})

    else
        view_diff({"HEAD"},{fspec})
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
local status:=arr[pos][1]
local fspec:=arr[pos][2]

    if( status[2]==" " )
        //már indexelve van,
        //az indexelés után nincs módosítva,
        //nincs értelme az add-nak
        return .t.
    end

    rundbg("git add "+fn_escape(fspec))
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
local status:=arr[pos][1]
local fspec:=arr[pos][2]

    if( status[1]==" " .or. status=="??" )
        //nincs indexelve
        //nincs értelme resetelni
        return .t. //marad a brwloop-ban
    end
    
    if( status[1]=="R" )
        fspec::=replace_name
        if( valtype(fspec)=="A" )
            //az átnevezés esete
            //így néz ki a browseban:
            //  R_   regi_nev -> uj_nev
            //a régi és új fájlt is resetelni kell

            rundbg("git reset -q -- "+fn_escape(fspec[1]))
            rundbg("git reset -q -- "+fn_escape(fspec[2]))
        end
    else
        rundbg("git reset -q -- "+fn_escape(fspec))
    end

    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


********************************************************************************************
static function checkout(brw,reread)

local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local fspec:=arr[pos][2]::alltrim
local status:=arr[pos][1]
local result

    if( status=="@@" )
        //technikai sor
        return .t.

    elseif( status=="??" )
        //untracked fájl
        //nincs benne a repóban
        //nem lehet checkoutolni
        return .t.

    elseif( status=="A " )
        //ujonnan indexelt fájl
        //nincs benne a repóban
        //nem lehet checkoutolni
        return .t.

    elseif( right(fspec,1)==dirsep() )
        //directoryt egyelőre nem checkoutolunk
        return .t.

    elseif( "M"$status )
        //módosítások elveszhetnek
        if( 2>alert("Checkout may overwrite changes!",{"Escape","Continue"}))
            return .t.
        end
    end
    
    if( "R"$status )
        fspec::=replace_name
        if( valtype(fspec)=="A" )
            //mv src dst
            //mire vonatkozhat a checkout?
            //src a commitban megvan, a wt-ből kikerült (hacsak...)
            //dst a wt-ben új, hacsak éppen nem felülírt valamit
            //mindkettőt lehet értelme checkoutolni
            //de valószínűbb, hogy az src kell
            
            fspec:=fspec[1]
        else
            return .t. //??? 
        end
    end

    if( status=="AM" )
        //új, indexelt, de indexelés után módosított fájl, 
        //nem a commitból, hanem az indexből checkoutoljuk,
        //azért itt nem kell resetelni

    //elseif( status=="MM" .and. 2>alert(....) )
        //itt lehetne checkoutolni
        //a commitból és az indexből is

    else
        rundbg("git reset -q -- "+fn_escape(fspec))
    end
    result:=output_of("git checkout -- "+fn_escape(fspec))
    if( "error:"$result .or. "fatal:"$result )
        zbrowseNew(result,brw:ntop,brw:nleft,brw:nbottom,brw:nright):loop
    end

    reread:=.t.  //uj brw array lesz
    return .f.   //jelenlegi brwloop-bol ki


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
static function replace_name(fspec)
local pos:=at("->",fspec)

    if( pos>0 )
        fspec:={fspec[1..pos-1]::alltrim,fspec[pos+2..]::alltrim}
    end

    //az átnevezés esete
    //így néz ki a browseban:
    //  R_   regi_nev -> uj_nev
    //vagyis ilyenkor két fspec is van

    return fspec // "fspec"  vagy {"fspec1","fspec2"}


********************************************************************************************
