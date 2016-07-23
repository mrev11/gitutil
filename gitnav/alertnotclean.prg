
********************************************************************************************
function alert_if_not_committed()
    alert( "To prevent overwriting local changes;function is allowed only in fully committed state!",{"Escape"} )


********************************************************************************************
function alert_if_not_committed_force()
    return alert( "To prevent overwriting local changes;function is allowed only in fully committed state!",{"Escape","Force"} )


********************************************************************************************
