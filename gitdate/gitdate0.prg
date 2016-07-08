
// Minden fájlra felteszi a fájlt utoljára módosító commit dátumát.
// A working directory gyökeréből kell indítani (ahol .git van).
// Hibák:
//  Olyan fájlok idejét is módosítja, amik kikerültek a gitből.
//  Újnak tekinti az átnevezett vagy átmásolt fájlokat.

**************************************************************************************
function main()

local pipe //{rd,wr}
local rl,line
local hash:=simplehashNew()
local ptab,peol,path,da,ti

    set date format "yyyy-mm-dd"

    pipe:=child( 'git whatchanged -m --pretty=Date:%ai' )
    rl:=readlineNew(pipe[1])
    fclose(pipe[2])

    while( NIL!=(line:=rl:readline) )
        //?? line

        if( at(a"Date:",line)==1 )
            da:=line::substr(6,10)::bin2str::ctod
            ti:=line::substr(17,8)::bin2str //timezone?

        elseif( at(a":",line)==1 )
            ptab:=rat(x"09",line)
            peol:=rat(x"0a",line)
            
            if( line[ptab-1]$a"AM"  )
                path:=line[ptab+1..peol-1]
                if( hash[path]==NIL )
                    hash[path]:=.t. //{da,ti}
                    setfdati(path,da,ti) //már nem létező fájlokra hatástalan
                end
            end
        end
    end

    fclose(pipe[1])

    //hash:list
    //?


**************************************************************************************
