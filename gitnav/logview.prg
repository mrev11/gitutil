
********************************************************************************************
function logview(brw)

//local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit1:=arr[pos][2]
local commit2
local rl,line
local gitcmd
local logarr:={}
local logbrw


    if( pos>=len(arr) )
        return .t.
    end
    
    commit2:=arr[pos+1][2]  //eggye  régebbi

    gitcmd:="git log --date=iso-local --stat --summary "+commit2+".."+commit1
    //memowrit("gitcmd",gitcmd)
    rl:=read_output_of(gitcmd)
    while( NIL!=(line:=rl:readline) )
        aadd(logarr,{ line::bin2str::strtran(chr(10),"") })
    end


    logbrw:=brwCreate(0,0,maxrow(),maxcol())

    brwArray(logbrw,logarr)
    brwColumn(logbrw,"",brwAblock(logbrw,1),replicate("X" ,maxcol()-2))
    logbrw:colorspec:="w/n,rg+/n,w+/n,rg+/n,r/n"
    logbrw:getcolumn(1):colorblock:={|x|linecolor(x)}
    logbrw:headsep:=""
    brwMenuname(logbrw,logarr[1][1]::alltrim)
    brwMenu(logbrw,"",logarr[3][1]::alltrim,{||.t.})  //írás a help mezőbe 



    brwShow(logbrw)
    brwLoop(logbrw)
    brwHide(logbrw)

    //restscreen(,,,,scrn)
    return .t.


********************************************************************************************
static function linecolor(x)
local color
    if( x[1..6] == "commit"  )
        color:={4}
    elseif( x[1..7] == "Author:"  )
        color:={3}
    elseif( x[1..5] == "Date:"  )
        color:={3}
    else
        color:={1}
    end
    return color

********************************************************************************************
