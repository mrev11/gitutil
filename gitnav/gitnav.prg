
#include "directry.ch"

// browseolja a commitokat
//
//  "Branch"    kapcsol a különböző branchok között
//  "Checkout"  előveszi a kiválasztott commitot  (checkout -f; clean -fdx)


static repo_clean:=repo_clean()

********************************************************************************************
function main()

local brw
local branchmenu
local com:={{""}},n
local err

    setcursor(0)

    //if( !direxist(".git") )
    //    alert( "Not a git working directory - Quit." )
    //    quit
    //end
    
    
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

    brwColumn(brw,"Commit",brwAblock(brw,1),replicate("X",maxcol()-2))

    brwMenu(brw,"Branch","Set current branch",branchmenu:=branchmenu(brw,{}))
    brwMenu(brw,"Checkout","Checkout the highlighted commit",{||checkout(brw)})


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
    if( !repo_clean )
        alert("There are modified file(s) in the working tree,;";
              +"checkout would destroy all changes!")
    else
        b::=strtran("*","")
        run("git checkout -f "+b)      //force nélkül a módosításokat nem írja felül
        run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
    end
    break("X") //kilép brwLoop-ból


********************************************************************************************
function checkout(brw)
local commit
    if( !repo_clean )
        alert("There are modified file(s) in the working tree,;";
              +"checkout would destroy all changes!")
    else
        commit:=brwArray(brw)[brwArrayPos(brw)][1]
        commit::=split(" ")
        commit:=commit[1]
        run("git checkout -f "+commit) //force nélkül a módosításokat nem írja felül
        run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
    end
    break("X") //kilép brwLoop-ból


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
