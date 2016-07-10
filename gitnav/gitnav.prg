
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
local com:={{"","",""}},n
local rl,line,pos
local err

    change_to_gitdir()

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

    brwColumn(brw,"Branch",brwAblock(brw,1),replicate("X",6))
    brwColumn(brw,"Commit",brwAblock(brw,2),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,3),replicate("X",maxcol()-21))

    brwMenu(brw,"Branch","Set current branch",branchmenu:=branchmenu(brw,{}))
    brwMenu(brw,"Checkout","Checkout the highlighted commit",{||checkout(brw)})
    brwMenu(brw,"Compare^","View changes caused by this commit",{||compare__(brw)})
    brwMenu(brw,"Compare-HEAD","View changes between this commit and HEAD",{||compare_h(brw)})
    brwMenu(brw,"SoftReset","Reset to the highlighted commit",{||reset(brw)})

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
        
        fill_status(com)

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
function setbranch(b)
    if( !repo_clean )
        alert("There are modified file(s) in the working tree,;";
              +"checkout would destroy all changes!",{"Escape"})
        return .t.
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
              +"checkout would destroy all changes!",{"Escape"})
        return .t.
    else
        commit:=brwArray(brw)[brwArrayPos(brw)][2]
        run("git checkout -f "+commit) //force nélkül a módosításokat nem írja felül
        run("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
    end
    break("X") //kilép brwLoop-ból


********************************************************************************************
function compare__(brw)
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
function compare_h(brw)
local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
local head:=arr[1][2]
    run( "gitview.exe "+commit+" "+head )
    restscreen(,,,,scrn)
    return .t.



********************************************************************************************
function reset(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    run( "git reset --soft "+commit)
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
