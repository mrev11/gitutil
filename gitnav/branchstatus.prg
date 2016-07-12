

//Ezek a programok feltételezik,
//hogy a branchek remote megfelelőjének ugyanaz a neve,
//mint a lokális branchnak. Ezenkívül feltételezzük,
//hogy a branchok neve már az első betűben különbözik.
//Ha ezek nem teljesülnek, akkor a gitnav browse első
//oszlopa nem mutat értelmes infót.


***************************************************************************************
function mergebase()

local rl,line
local branch,current,n
local base,rbranch

    branch:=list_of_branches(@current)
    rbranch:=list_of_remote_branches(@current)

    for n:=1 to len(branch)
        base:=commitid_of_mergebase(current,branch[n])
        branch[n]:={branch[n]::lower,base}
    next
   
    for n:=1 to len(rbranch)
        base:=commitid_of_remote_branch(rbranch[n])
        if(!empty(base))
            aadd(branch,{rbranch[n]::split(dirsep())::atail::upper,base})
        end
    next
   
    
    //? branch

    return branch // {{branch-1,base-1},{branch-2,base-2}, ... }


***************************************************************************************
function branch_status(com)

local mb:=mergebase()
local n,id,x,c
local status:=""

    for n:=1 to len(com)
        //com[n] = {status, commitid, message}
        id:=com[n][2]
        
        x:=1
        while( x<=len(mb) )
            if( !(mb[x][2]!=id) )
                //id hosszában egyenlő!

                c:=mb[x][1][1] //branch első betűje
                if( islower(c) )
                    //local
                    status+=c
                else
                    //remote
                    if( lower(c)$status )
                        status::=strtran(lower(c),upper(c))
                    else
                        status+=c
                    end
                end

                //kivesszük
                adel(mb,x)
                asize(mb,len(mb)-1)
                
                //? id, "["+status+"]"
            else
                x++
            end
        end
        com[n][1]:=status
    next

    //Ez végigmegy az összes commiton,
    //és mindegyiknél bejelöli, hogy mely branchokban van benne.
    //Ha egy commit benne van egy lokális branchban, akkor a status 
    //oszlopban megjelenik a branch kezdőbetűje kisbetűvel.
    //Ha a commitot már pusholtuk, azaz benne van a remote 
    //branchban (is), akkor a branch jele nagybetűvel szerepel.
    //Ez persze csak akkor értelmes, ha az egymáshoz tartozó
    //lokális és remote branchoknak azonos a neve. Az sem árt,
    //ha a branch nevek az első betűben különböznek. 
    //Azért jó látni, hogy egy ág meddig volt pusholva,
    //mert annál rövidebbre nem szabad visszavágni. 
    
    
***************************************************************************************
