

********************************************************************************************
function branchmenu(brw,branchmenu)
local rl,line,current
    asize(branchmenu,0)
    rl:=read_output_of("git branch")
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(branchmenu,{line,mkblock_setbranch(line)})
        if( "*"$line )
            current:=line[2..]::alltrim
            brwMenuName(brw,branch_state_menuname(current))
        end
    end
    rl:close

    return branchmenu


static function mkblock_setbranch(b)
    return {||setbranch(b)}


********************************************************************************************
static function setbranch(b)
    if( !repo_clean() )
        alert_if_not_committed()
    else
        b::=strtran("*","")
        rundbg("git checkout -f "+b)      //force nélkül a módosításokat nem írja felül
        rundbg("git clean -fxd")          //-f(force) -x(ignored files) -d(directories)
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

