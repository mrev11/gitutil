

//Ezek a programok feltételezik,
//hogy a branchek remote megfelelőjének ugyanaz a neve,
//mint a lokális branchnak. Ezenkívül feltételezzük,
//hogy a branchok neve már az első betűben különbözik.
//Ha ezek nem teljesülnek, akkor a gitnav browse első
//oszlopa nem mutat értelmes infót.


***************************************************************************************
function merge_status()

local rl,line
local branch,current,n
local base,tip,rbranch

    branch:=list_of_branches(@current)
    rbranch:=list_of_remote_branches()

    for n:=1 to len(branch)
        base:=commitid_of_mergebase(current,branch[n])
        tip:=name_to_commitid(branch[n])
        branch[n]:={branch[n],base,tip}
    next

    for n:=1 to len(rbranch)
        base:=commitid_of_mergebase(current,rbranch[n])
        tip:=name_to_commitid(rbranch[n])
        if(!empty(base))
            aadd(branch,{rbranch[n],base,tip})
        end
    next


#ifdef NOTDEFINED
    //branch info
    rundbg("git branch -a")
    for n:=1 to len(branch)
        ?? "  "
        ?? if(branch[n][2]==branch[n][3],"","!")
        ?? branch[n][2][1..10], branch[n][3][1..10]
        ?? " ",branch[n][1]
        ?
    next
#endif    

    dispname(branch)
    asortkey(branch,{|x|x[1]})  

    return branch // {{branch1,base1,tip1},{branch2,base2,tip2}, ... }


***************************************************************************************
function dispname(branch)   // branch[n][1] <- dispname
local n,name
    for n:=1 to len(branch)
        name:=branch[n][1]::split("/")
        if( len(name)<2 )
            branch[n][1]:=name[1] //local
        else
            branch[n][1]:=name[2]+"@"+name[1] //remote
        end
    next


***************************************************************************************
function merge_status_short(branch:=merge_status())
local n,sn

//  branch              local
//  remote/branch       regebbi
//  branch@remote       attekinthetobb

    for n:=1 to len(branch)
        sn:=branch[n][1]

        if( "@"$sn  )
            sn::=split("@")
            sn:=sn[1][1]+sn[2][1]   //[b]ranch [r]remote

        elseif( "/"$sn )
            sn::=split("/")
            sn:=sn[2][1]+sn[1][1]   //[b]ranch [r]remote

        else
            sn:=sn[1]               //[b]ranch (local)
        end

        branch[n][1]:=sn //short name
    next
    return branch


    
***************************************************************************************
