
//close metódussal bővítve
//debugolással bővítve

****************************************************************************
class readlinedbg(readline)
    method close
    method readline


****************************************************************************
static function readlinedbg.readline(this)
local line:=this:(readline)readline
    if( line!=NIL .and. "o"$debug("o") )
        ?? line //a végén bin(10)
    end
    return line  //a következő sor, vagy NIL, ha vége a filének


****************************************************************************
static function readlinedbg.close(this)
    return fclose(this:fd)

****************************************************************************

