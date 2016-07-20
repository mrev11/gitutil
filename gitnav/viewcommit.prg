
********************************************************************************************
function viewcommit(brw)
//local scrn:=savescreen()
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit1:=arr[pos][2]
local commit2

    if( pos<len(arr) )
        commit2:=arr[pos+1][2]  //eggye  régebbi
        browse(commit1,commit2)
    end

    //restscreen(,,,,scrn)
    return .t.


********************************************************************************************
static function browse(commit1, commit2)

local gitcmd,rl,line
local brw, arr:={}

    gitcmd:="git log --date=iso-local --stat --summary "+commit2+".."+commit1
    //memowrit("gitcmd",gitcmd)
    rl:=read_output_of(gitcmd)
    while( NIL!=(line:=rl:readline) )
        aadd(arr,{ line::bin2str::strtran(chr(10),"") })
    end
    rl:close

    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwArray(brw,arr)
    brwColumn(brw,"",brwAblock(brw,1),replicate("X" ,maxcol()-2))
    brw:colorspec:="w/n,rg+/n,w+/n,rg+/n,r/n"
    brw:getcolumn(1):colorblock:={|x|linecolor(x)}
    brw:headsep:=""
    brwMenuname(brw,arr[1][1]::alltrim)
    brwMenu(brw,"",arr[3][1]::alltrim,{||.t.})  //írás a help mezőbe 

    brwShow(brw)
    brwLoop(brw)
    brwHide(brw)



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
