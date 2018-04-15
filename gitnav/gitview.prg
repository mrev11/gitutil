
function main(*)
local arg:={*}
    change_to_gitdir()
    if( len(arg)==1 )
        do_gitview(arg[1],arg[1]+"^")
    else
        do_gitview(*)
    end



//korabban 
//
//  gv commit
//
//a commit es a HEAD kozotti kulonbseget mutatta
//de hasznosabb a commit es commit^ kulonbseget mutatni
//(a korabbi mukodes eletheto igy: gv commit HEAD)