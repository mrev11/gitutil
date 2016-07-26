

function branch_state_menuname(cb:=current_branch())

local menuname:='['+cb

    if( merge_mode() )
        menuname+=" MERGE"

    elseif( ' rebasing '$cb  )
        menuname+=" REBASE"

    elseif( !repo_clean(.t.) )
        menuname+=" DIRTY"
    end

    menuname+=']'
    return menuname

    
