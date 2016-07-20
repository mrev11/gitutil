

********************************************************************************************
function main()

local brw
local branchmenu
local com:={{"",""}},n
local rl,line,pos
local err

    change_to_gitdir()

    setcursor(0)

    
    brw:=brwCreate(0,0,maxrow(),maxcol())
    brwArray(brw,com)

    brwColumn(brw,"Commit",brwAblock(brw,1),replicate("X",7))
    brwColumn(brw,"Message",brwAblock(brw,2),replicate("X",maxcol()-12))

    brwMenu(brw,"Reload","Re-execute git reflog command",{||.f.})
    //brwMenu(brw,"Reset","Soft reset to the highlighted commit",{||reset(brw)})

    brwApplyKey(brw,{|b,k|appkey(b,k)})
    brwMenuName(brw,"[reflog]")

    brw:colorspec:="w/n,n/w,w+/n,rg+/n"
    brw:getcolumn(1):colorblock:={|x|{4}}
    

    while(.t.)
        //branchmenu(brw,branchmenu) //frissíti

        asize(com,0)
        rl:=read_output_of("git reflog")
        while( (line:=rl:readline)!=NIL )
            line::=bin2str
            line::=strtran(chr(10),"")
            pos:=at(" ",line)
            aadd(com,{line[1..pos-1],line[pos+1..]})
        end
        rl:close
        if(empty(com))
            exit
        end
        
        brw:gotop
        brwShow(brw)
        begin
            brwLoop(brw)
        recover err <C>
            //újraolvas
        end
    end    


********************************************************************************************
static function appkey(b,k)
    if( k==27 )
        quit
    end


********************************************************************************************
