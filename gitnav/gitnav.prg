
#include "directry.ch"


// browseolja a commitokat
//
//  "Branch"    kapcsol a különböző branchok között
//  "Checkout"  előveszi a kiválasztott commitot  (checkout -f; clean -fdx)
//  "Compare"   savex-szel összehasonlítja a HEAD-et és a kiválasztott commitot 


static repo_clean:=repo_clean()

********************************************************************************************
function main()

local brw
local branchmenu
local com:={{""}},n
local err

    setcursor(0)

    if( !direxist(".git") )
        ? "Not a git working directory - Quit."
        ?
        quit
    end
    
    
    if( repo_clean  )
        //alert("repo clean")
    else
        alert("Working directory is not clean!")
        //ha most a user továbbmegy és checkout-ol,
        //akkor a working directoriban levő esetleges
        //változások elvesznek.
    end

    
    brw:=brwCreate(0,0,maxrow(),maxcol())

    brwArray(brw,com)

    brwColumn(brw,"Commit",brwAblock(brw,1),replicate("X",maxcol()-2))

    brwMenu(brw,"Branch","Set current branch",branchmenu:=branchmenu(brw,{}))
    brwMenu(brw,"Checkout","Checkout the highlighted commit",{||checkout(brw)})
    brwMenu(brw,"Compare","Compare current commit with the highlighted one",{||compare(brw)}) 


    brwApplyKey(brw,{|b,k|appkey(b,k)})
    brwMenuName(brw,"[GitNavig]")

    while(.t.)
        branchmenu(brw,branchmenu) //frissíti

        run(" git log --pretty=oneline  --abbrev-commit >log1")
        com:=memoread("log1") //commits
        ferase("log1")
        com::=split(chr(10))
        for n:=1 to len(com)
            com[n]:={com[n]}
        next

        brwArray(brw,com)

        brw:gotop
        brwShow(brw)
        begin
            brwLoop(brw)
        recover err <C>
            //újraolvas
        end
    end    


********************************************************************************************
function appkey(b,k)
    if( k==27 )
        quit
    end


********************************************************************************************
function branchmenu(brw,branchmenu)
local log,branch,n
    run("git branch >log2")
    branch:=memoread("log2") //branches
    ferase("log2")
    branch::=split(chr(10))
    asize(branchmenu,0)
    for n:=1 to len(branch)
        if( "*"$branch[n] )
            brwMenuName(brw,'['+branch[n][2..]::alltrim+']' )
        end
        aadd(branchmenu,{branch[n],mkblock(branch[n])})
    next
    return branchmenu


static function mkblock(b)
    return {||setbranch(b)}


********************************************************************************************
function setbranch(b)
    b::=strtran("*","")
    run("git checkout -f "+b)      //force nélkül a módosításokat nem írja felül
    run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
    break("X") //kilép brwLoop-ból


********************************************************************************************
function checkout(brw)
local commit:=brwArray(brw)[brwArrayPos(brw)][1]
    commit::=split(" ")
    commit:=commit[1]
    run("git checkout -f "+commit)     //force nélkül a módosításokat nem írja felül
    run("git clean -fxd")
    break("X") //kilép brwLoop-ból

/*
function checkout1(brw)
local commit:=brwArray(brw)[brwArrayPos(brw)][1]
    commit::=split(" ")
    commit:=commit[1]
    run("git reset "+commit)
    run("git checkout .")
    run("git clean -fxd")
    break("X") //kilép brwLoop-ból

    ugyanaz, kivéve, hogy levágja az ág végét
    nehezebb visszatalálni az ág végére
    a 'git reflog'-ból lehet csak kitalálni korábbi HEAD-et
*/


********************************************************************************************
//nemannyira jó resetelni

function reset(brw)
local commit:=brwArray(brw)[brwArrayPos(brw)][1]
    commit::=split(" ")
    commit:=commit[1]
    run("git reset "+commit)
    break("X") //kilép brwLoop-ból
    
/*
    levágja az ág végét
    az ág új végének megfelelő állapotba teszi az indexet
    de nem veszi elő a fájlokat (megmarad a wd tartalma)
    azaz eldob valahány commitot az ág végéről
    nem jó ilyet csinálni, ha emiatt eltérés keletkezik
    a remote repótól
*/    


********************************************************************************************
function compare(brw)
local commit:=brwArray(brw)[brwArrayPos(brw)][1]
    commit::=split(" ")
    commit:=commit[1] //ez van kiválasztva

    run ("find . | xargs touch -t 202202220000")
    run ("rm -rf .git/compare")
    run ("mkdir  .git/compare")
    run ("ln -sr .git .git/compare")
    dirchange(".git/compare")
    run("git checkout -f "+commit)
    run ("find . | xargs touch -t 201101110000" )
    run ("export USER=x && fts -f")
    run("cp .FILETIME_x ../../.FILETIME_x")
    dirchange("../..")
    run ("ftr")
    run("savex.exe -s.git/compare  -mw -r:.git:" )
    run ("rm -rf .git/compare")

    checkout(brw)


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
