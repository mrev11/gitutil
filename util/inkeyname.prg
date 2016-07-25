

#ifdef _CCC2_
#include "inkeyname_ccc2.ch"
#else
#include "inkeyname_ccc3.ch"
#endif

static inkeyname:=inkeyname_init()


**************************************************************************************
static function inkeyname_init()
local a:=array(1000)
local x:=inkey::split(chr(10)),n,p
local name,code
    for n:=1 to len(x)
        p:=at(" ",x[n])
        if(p>1)
            name:=x[n][1..p-1]
            code:=x[n][p..]::val
            a[code+600]:=name
        end
    next
    return a
    

**************************************************************************************
function inkeycode2name(code)
local name:=inkeyname[code+600]
    if(name==NIL)
        name:="K_"+chr(code)::upper
    end
    return name


**************************************************************************************



