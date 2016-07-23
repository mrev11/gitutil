
#include "inkey.ch"
#include "directry.ch"

// browseolja a commitokat
//
//  "Branch"    branchok között vált (checkout -f <branch>; clean -fxd)
//  "Fetch"     fetch kiválasztott remoteból, vagy mindből (fetch --all --prune)
//  "Browse"    browseolja a commitban levő fájlokat (readonly)
//  "PrepCommit" diffeli a HEAD-et és indexet, végrehajtja a commitot
//  "DiffPrev"  diffeli a kiválasztottat az eggyel régebbivel (readonly)
//  "DiffHead"  diffeli a kiválasztottat a HEAD-del (readonly)
//  "Reset"     HEAD-et a kiválasztott commithoz viszi  (reset --soft <commit>)
//  "Snapshot"  előveszi a kiválasztott commitot (checkout -f <commit>; clean -fxd)


********************************************************************************************
function main()

local brw
local branchmenu
local fetchmenu
local com:={{"","",""}},n
local rl,line,pos
local err

    change_to_gitdir()
    setup_checkout_hook()

    setcursor(0)

    if( repo_clean()  )
        //alert("repo clean")
    else
        //ez feltartja a használatot
        //alert( "Working directory is not clean!")
        //quit
        //ha most a user továbbmegy és checkout-ol,
        //akkor a working directoriban levő esetleges
        //változások elvesznek.
    end

    
    brw:=brwCreate(0,0,maxrow(),maxcol())

    brwArray(brw,com)

    brwColumn(brw,"Branch",brwAblock(brw,1),replicate("X",25))
    brwColumn(brw,"Commit",brwAblock(brw,2),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,3),replicate("X",maxcol()-40))

    brwMenu(brw,"Branch","Change to another branch",branchmenu:=branchmenu(brw,{}))
    brwMenu(brw,"Fetch","Download changes from remotes",fetchmenu:=fetchmenu(brw,{}))
    brwMenu(brw,"Browse","Browse files of selected commit",{||browse_commit(brw)})
    brwMenu(brw,"PrepCommit","Prepare and execute commit",{||prepcommit(brw)})
    brwMenu(brw,"DiffPrev","View changes caused by the selected commit",{||diffprev(brw)})
    brwMenu(brw,"DiffHead","View changes between selected commit and HEAD",{||diffhead(brw)})
    brwMenu(brw,"Reset","Reset tip of current branch to the selected commit",{||reset(brw)})
    brwMenu(brw,"Snapshot","Checkout the selected commit (->detached head)",{||checkout(brw)})

    brwApplyKey(brw,{|b,k|appkey(b,k)})
    brwMenuName(brw,"[GitNavig]")

    brw:colorspec:="w/n,n/w,w+/n,rg+/n"
    brw:getcolumn(1):colorblock:={|x|{3}}
    brw:getcolumn(2):colorblock:={|x|{4}}
    

    while(.t.)
        branchmenu(brw,branchmenu) //frissíti

        asize(com,0)
        //rl:=read_output_of("git log --oneline --decorate")
        rl:=read_output_of("git log --pretty=oneline  --abbrev-commit")
        while( (line:=rl:readline)!=NIL )
            if(debug())
                ?? line
            end
            line::=bin2str
            line::=strtran(chr(10),"")
            pos:=at(" ",line)
            aadd(com,{"?",line[1..pos-1],line[pos+1..]})
        end
        rl:close
        if(empty(com))
            exit
        end
        
        branch_status(com)
        rearrange_col_width(brw)

        brw:gotop
        brwShow(brw)
        begin
            brwLoop(brw)
        recover err <C>
            //újraolvas
        end
    end    


********************************************************************************************
static function appkey(b,k)
    if( k==K_ESC )
        quit
    elseif( k==K_INS )
        viewcommit(b)
    end


********************************************************************************************
static function checkout(brw)
local commit
    if( !repo_clean() )
        alert_if_not_committed()
        return .t.
    else
        commit:=brwArray(brw)[brwArrayPos(brw)][2]
        run("git checkout -f "+commit) //force nélkül a módosításokat nem írja felül
        run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
        link_local()
        return .f. //kilép brwLoop-ból
    end


********************************************************************************************
static function diffprev(brw)
local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    if( pos<len(arr) )
        run( "gitview.exe "+commit+"^ "+commit )
    end
    restscreen(,,,,scrn)
    return .t.


********************************************************************************************
static function diffhead(brw)
local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=arr[1][2]
    if( pos==1 )
        //HEAD-et a HEAD-del összehasonlítani
        //nincs értelme, helyette: HEAD<->index
        //inkább külön menübe --> prepare commit
        //run( "gitview.exe" )
    else
        run( "gitview.exe "+commit+" HEAD" )
    end
    restscreen(,,,,scrn)
    return .t.


********************************************************************************************
static function prepcommit(brw)
local scrn:=savescreen()
local current
local branch:=list_of_branches(@current)
local tip:=name_to_commitid(current)
    run( "gitview.exe" )
    restscreen(,,,,scrn)
    return (tip==name_to_commitid(current))

    //ha nem történt commit, TRUE-t ad -> marad brwLoop-ban
    //ha történt commit, FALSE-t ad -> kilép a brwLoop-ból -> új inicializálások

********************************************************************************************
static function reset(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    run( "git reset --soft "+commit)
    return .f. //kilép brwLoop-ból
    
    //A resetet általában arra használjuk, hogy lerövidítsük 
    //az aktuális ágat. A soft reset nem módosítja az indexet
    //és a working tree-t. A reset után végrehajtunk egy
    //add-ot és egy commit-ot, amivel a lerövidült branch
    //végén levő commitban ott lesz az worktree friss tartalma.
    //Az ágat nem szabad rövidebbre vágni, mint az utoljára 
    //pusholt commit. Ha a reset után meggondoljuk magunkat,
    //vissza lehet lépni egy 'git reset ORIG_HEAD' művelettel.


***************************************************************************************
static function branch_status(com)

local mb:=merge_status_short()
local n,id,x,c
local status:=""

    for n:=1 to len(com)
        //com[n] = {status, commitid, message}
        id:=com[n][2]
        
        x:=1
        while( x<=len(mb) )
            if( !(mb[x][2]!=id) )
                //id hosszában egyenlő!
                if( !empty(status) )
                    status+=" "
                end
                status+=mb[x][1]
                if( mb[x][2]!=mb[x][3] )
                    status+="!"
                end

                //kivesszük
                adel(mb,x)
                asize(mb,len(mb)-1)
                
                //? id, "["+status+"]"
            else
                x++
            end
        end
        com[n][1]:=status
    next

    //Ez végigmegy az összes commiton,
    //és mindegyiknél bejelöli, hogy mely branchokban van benne.
    //Ha egy commit benne van egy lokális branchban, akkor a status 
    //oszlopban megjelenik a branch kezdőbetűje kisbetűvel.
    //Ha a commitot már pusholtuk, azaz benne van a remote 
    //branchban (is), akkor a branch jele nagybetűvel szerepel.
    //Ez persze csak akkor értelmes, ha az egymáshoz tartozó
    //lokális és remote branchoknak azonos a neve. Az sem árt,
    //ha a branch nevek az első betűben különböznek. 
    //Azért jó látni, hogy egy ág meddig volt pusholva,
    //mert annál rövidebbre nem szabad visszavágni. 
    

********************************************************************************************
static function rearrange_col_width(brw)
local wstat:=brw::brwarray::atail[1]::len::max(6) //ekkora szélesség kell
local wmesg:=(maxcol()-wstat-15)::max(10)

    brw:column[1]:width:=wstat
    brw:column[1]:picture:=replicate("X",wstat)
    brw:column[3]:width:=wmesg
    brw:column[3]:picture:=replicate("X",wmesg)
     

********************************************************************************************
