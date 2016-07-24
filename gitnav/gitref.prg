
#include  "inkey.ch"

********************************************************************************************
function main()

local brw
local com:={{"","",""}},n
local current
local menuname
local rl,line,pos
local err

    change_to_gitdir()

    setcursor(0)
    
    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwArray(brw,com)

    brwColumn(brw,"Status",brwAblock(brw,1),replicate("X",25))
    brwColumn(brw,"Commit",brwAblock(brw,2),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,3),replicate("X",maxcol()-40))

    brwMenu(brw,"Reset","Move HEAD to the highlighted commit",{||reset(brw)})

    brwApplyKey(brw,{|b,k|appkey(b,k)})

    menuname:="["
    list_of_branches(@current)
    menuname+=current
    menuname+=" ORIG_HEAD="
    menuname+=name_to_commitid("ORIG_HEAD")[1..7]
    menuname+="]"
    brwMenuName(brw,menuname)

    brw:colorspec:="w/n,n/w,w+/n,rg+/n"
    brw:getcolumn(1):colorblock:={|x|{3}}
    brw:getcolumn(2):colorblock:={|x|{4}}
    

//    while(.t.)
        asize(com,0)
        rl:=read_output_of("git reflog")
        while( (line:=rl:readline)!=NIL )
            line::=bin2str
            line::=strtran(chr(10),"")
            pos:=at(" ",line)
            aadd(com,{"", line[1..pos-1],line[pos+1..]})
        end
        rl:close
        if(empty(com))
            com:={{"","",""}}
        end

        branch_status(com)
        rearrange_col_width(brw)
        
        brwShow(brw)
        brwLoop(brw)
        brwHide(brw)
//    end    


********************************************************************************************
static function appkey(b,k)
    if( k==K_ESC )
        quit
    elseif( k==K_INS )
        viewcommit(b)
    end


********************************************************************************************
static function reset(brw)
local arr:=brwArray(brw)
local pos:=brwArrayPos(brw)
local commit:=arr[pos][2]
    rundbg( "git reset --soft "+commit)
    return .f. //kilép brwLoop-ból


***************************************************************************************
static function branch_status(com)

local mb:=merge_status_short()
local n,id,x,c
local status:=""
    
    aadd(mb,{"OH","",name_to_commitid("ORIG_HEAD")})

    for n:=1 to len(com)
        //com[n] = {status, commitid, message}
        
        id:=com[n][2]
        status:=""
        x:=1
        while( x<=len(mb) )
            //mb[x] = {branch, base, tip}

            if( !(mb[x][3]!=id) )
                //id hosszában egyenlő!
                if( !empty(status) )
                    status+=" "
                end
                status+=mb[x][1]

                //kivesszük
                adel(mb,x)
                asize(mb,len(mb)-1)
            else
                x++
            end
        end
        com[n][1]:=status
    next


********************************************************************************************
static function rearrange_col_width(brw)

local wstat:=6
local wmesg
local arr:=brwArray(brw),n

    for n:=1 to len(arr)
        wstat::=max(arr[n][1]::len)
    next

    wmesg:=(maxcol()-wstat-15)::max(10)

    brw:column[1]:width:=wstat
    brw:column[1]:picture:=replicate("X",wstat)
    brw:column[3]:width:=wmesg
    brw:column[3]:picture:=replicate("X",wmesg)
     

********************************************************************************************
