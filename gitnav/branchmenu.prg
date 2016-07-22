

********************************************************************************************
function branchmenu(brw,branchmenu)
local rl,line,menuname
    asize(branchmenu,0)
    rl:=read_output_of("git branch")
    while( (line:=rl:readline)!=NIL )
        if(debug())
            ?? line
        end
        line::=bin2str
        line::=strtran(chr(10),"")
        aadd(branchmenu,{line,mkblock_setbranch(line)})
        if( "*"$line )
            menuname:='['
            menuname+=line[2..]::alltrim
            if( !repo_clean() )
                menuname+=" DIRTY"
            end
            menuname+=']'
            brwMenuName(brw,menuname)
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

