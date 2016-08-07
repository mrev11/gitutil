

********************************************************************************************
function repo_clean(reread:=.f.)
static repo_clean
    if( repo_clean==NIL .or. reread )
        repo_clean:=repo_clean_init()
    end
    return repo_clean 


********************************************************************************************
static function repo_clean_init()
local rl,line
    rl:=read_output_of("git status --short")
    line:=rl:readline
    rl:close
    return line::empty // TRUE: clean


********************************************************************************************
