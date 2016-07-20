
#include "inkey.ch"
#include "directry.ch"

// browseolja a commitokat
//
//  "Branch"    kapcsol a különböző branchok között
//  "Browse"    browse-olja a commitban levő fájlokat
//  "Compare^"  összehasonlítja az kiválasztottat az eggyel régebbivel 
//  "CompareH"  összehasonlítja az kiválasztottat a HEAD-del
//  "Reset"     A HEAD-et az kiválsztott commit-hoz viszi
//  "Snapshot"  előveszi a kiválasztott commitot  (checkout -f; clean -fdx)

static repo_clean:=repo_clean()

********************************************************************************************
function main()

local brw
local branchmenu
local com:={{"","",""}},n
local rl,line,pos
local err

    change_to_gitdir()

    setcursor(0)

    if( repo_clean  )
        //alert("repo clean")
    else
        alert( "Working directory is not clean!")
        //quit
        //ha most a user továbbmegy és checkout-ol,
        //akkor a working directoriban levő esetleges
        //változások elvesznek.
    end

    
    brw:=brwCreate(0,0,maxrow(),maxcol())

    brwArray(brw,com)

    brwColumn(brw,"Branch",brwAblock(brw,1),replicate("X",6))
    brwColumn(brw,"Commit",brwAblock(brw,2),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,3),replicate("X",maxcol()-21))

    brwMenu(brw,"Branch","View/change current branch",branchmenu:=branchmenu(brw,{}))
    brwMenu(brw,"Browse","Browse files of selected commit",{||browse_commit(brw)})
    brwMenu(brw,"Compare^","View changes caused by the selected commit",{||compare__(brw)})
    brwMenu(brw,"Compare-HEAD","View changes between selected commit and HEAD (or index)",{||compare_h(brw)})
    brwMenu(brw,"Reset","Soft reset to the selected commit",{||reset(brw)})
    brwMenu(brw,"Snapshot","Checkout the selected commit",{||checkout(brw)})

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
static function branchmenu(brw,branchmenu)
local rl,line
    asize(branchmenu,0)
    rl:=read_output_of("git branch")
    while( (line:=rl:readline)!=NIL )
        if(debug())
            ?? line
        end
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(branchmenu,{line,mkblock(line)})
        if( "*"$line )
            brwMenuName(brw,'['+line[2..]::alltrim+']' )
        end
    end
    rl:close

    return branchmenu


static function mkblock(b)
    return {||setbranch(b)}


********************************************************************************************
static function setbranch(b)
    if( !repo_clean )
        alert_if_not_committed()
    else
        b::=strtran("*","")
        run("git checkout -f "+b)      //force nélkül a módosításokat nem írja felül
        run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
        link_local()
        break("X") //kilép brwLoop-ból
    end
    
    //Pulldown menü blokkjának return értékével 
    //nem lehet szabályozni a brwLoopból való kilépést.
    //Ha a visszatérési érték szám, akkor a menü
    //lenyitott állapotban marad, és a return érték
    //szerinti sor lesz benne kiválasztva,
    //egyébként becsukódik.


********************************************************************************************
static function checkout(brw)
local commit
    if( !repo_clean )
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
static function compare__(brw)
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
static function compare_h(brw)
local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=arr[1][2]
    if( pos==1 )
        //HEAD-et a HEAD-del összehasonlítani
        //nincs értelme, helyette: HEAD<->index
        run( "gitview.exe" )
    else
        //run( "gitview.exe "+commit+" "+head )
        run( "gitview.exe "+commit+" HEAD" )
    end
    restscreen(,,,,scrn)
    return .t.


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


********************************************************************************************
static function repo_clean()

local rl,line
local pipe:=child("git status") //{pr,pw}
local result:=.f.

    fclose(pipe[2])
    rl:=readlineNew(pipe[1])
    while NIL!=(line:=rl:readline)
        if( a'nothing to commit, working directory clean' $ line )
            result:=.t.
        end
    end
    fclose(pipe[1])

    return result // TRUE: clean


********************************************************************************************
static function alert_if_not_committed()
    alert( "To prevent DISASTER;function is allowed only in fully committed state!",{"Escape"} )


********************************************************************************************
static function link_local()
local gitloc:=directory(".git/local/*"),n
    for n:=1 to len(gitloc)
        run( "ln -s .git/local/"+gitloc[n][1]+" ." )
    end

// Az a koncepció, .git/local-ban egyéni scriptek vannak
// amelyek mind ignoráltak, ezért  git clean -fXd törli őket
// az objectekkel és exekkel együtt, de csak a gyökérben
// levő linkjüket, a .git/local-ban levő tényleges fájlt nem.
// Most újra belinkelődnek a gyökérbe.

********************************************************************************************
