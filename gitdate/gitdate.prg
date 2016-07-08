
// Minden fájlra felteszi a fájlt utoljára módosító commit dátumát.
// A working directory gyökeréből kell indítani (ahol .git van).
// Csak azokkal a fájlokkal foglalkozik, amik az indexben vannak, 
// de ezek közül csak azoknak van ideje, amik commitolva is voltak,
// ezért clone, commit vagy reset utáni állapotban célszerű futtatni.

// Hasonló, mint getdate0, de az azonos tartalmú fájlok 
// mind ugyanazt a fájlidőt kapják, nevezetesen a legrégebbit.
// A getdate0 újnak tekint minden átnevezett vagy átmásolt fájlt,
// getdate ezzel szemben a blob alapján felismeri az egyező fájlokat.

**************************************************************************************
function main()

local pipe //{rd,wr}
local rl,line
local hash_path:=simplehashNew()
local hash_blob:=simplehashNew()
local ptab,peol,path,blob
local dati,da,ti,item

    set date format "yyyy-mm-dd"

    pipe:=child( 'git whatchanged -m --pretty=Date:%ai' )
    rl:=readlineNew(pipe[1])
    fclose(pipe[2])

    while( NIL!=(line:=rl:readline) )
        //?? line

        if( at(a"Date:",line)==1 )
            dati:=line::substr(6,19)::bin2str  //tz elhagyva

        elseif( at(a":",line)==1 )
            ptab:=rat(x"09",line)
            peol:=rat(x"0a",line)
            
            if( line[ptab-1]$a"AM"  )
                path:=line[ptab+1..peol-1] //filespec
                blob:=line::substr(27,7) //blob-sha1[1..7]
                if( hash_path[path]==NIL )
                    hash_path[path]:=blob
                    da:=hash_blob[blob]
                    if( da==NIL .or. da>dati )
                        hash_blob[blob]:=dati //legrégebbi
                    end
                end
            end
        end
    end

    fclose(pipe[1])

    //hash_path:list
    //hash_blob:list

/*    
    // Ez a kód átállítja azon filék idejét is,
    // amiket most ugyan nem követ a git, de régebben 
    // követett, és ezért szerepelnek régi commit-okban.
    // (Egy friss klónban persze csak követett filék vannak.)
  
    item:=hash_path:first
    while( item!=NIL )
        path:=item[1]
        blob:=item[2]
        dati:=hash_blob[blob]
        da:=dati[1..10]::ctod
        ti:=dati[12..19]
        setfdati(path,da,ti)
        item:=hash_path:next
    end
*/

    // Így az aktuálisan indexben levő filékre korlátozódik,
    // commit vagy reset utáni állapotban célszerű futtatni.

    pipe:=child('git ls-files') 
    rl:=readlineNew(pipe[1])
    fclose(pipe[2])
    while( NIL!=(line:=rl:readline) )
        path:=strtran(line,x"0a",a"")
        blob:=hash_path[path]
        if( blob==NIL )
            ? "not committed:",path
        else
            dati:=hash_blob[blob]
            da:=dati[1..10]::ctod
            ti:=dati[12..19]
            setfdati(path,da,ti)
        end
    end
    fclose(pipe[1])

**************************************************************************************



