


***************************************************************************************
function mergebase()

local rl,line
local branch,current,n
local base,origin

    branch:=list_of_branches(@current)

    for n:=1 to len(branch)
        base:=commitid_of_mergebase(current,branch[n])
        branch[n]:={branch[n],base}
    next
   
    origin:=origin(current)
    if( !empty(origin) )
        aadd(branch,{upper(current),origin})
    end
   
    
    //? branch

    return branch // {{branch-1,base-1},{branch-2,base-2}, ... }


***************************************************************************************
function fill_status(com)

local mb:=mergebase()
local n,id,x
local status:=""

    for n:=1 to len(com)
        //com[n] = {status, commitid, message}
        id:=com[n][2]
        
        x:=1
        while( x<=len(mb) )
            if( !(mb[x][2]!=id) )
                //id hosszában egyenlő!
                status+=mb[x][1][1] //branch első betűje
                adel(mb,x)
                asize(mb,len(mb)-1)
                
                //? id, "["+status+"]"
            else
                x++
            end
        end
        com[n][1]:=status
    next


***************************************************************************************
