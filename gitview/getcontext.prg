

#include "context.say"


**********************************************************************************
function getcontext(context)
local result
    context({|getlist|load(getlist)},;
                {|getlist|readmodal(getlist)},;
                    {|getlist|store(getlist,@result)})

    if( result==NIL )
        result:=context //az eredeti érték
    else
        result::=str::alltrim
    end
    return result

**********************************************************************************
static function load(getlist)
    g_context:picture:="9999999"
    g_context:varput:=3
    g_context:postblock:={|g|g:varget>=0}


**********************************************************************************
static function store(getlist,result)
    result:=g_context:varget
    return .t.

**********************************************************************************





















