
static repo_clean:=repo_clean_init()

********************************************************************************************
function repo_clean(reread:=.f.)
    if(reread)
        repo_clean:=repo_clean_init()
    end
    return repo_clean 


********************************************************************************************
static function repo_clean_init()
local rl,line

    //return 'nothing to commit, working directory clean' $ output_of("git status") // TRUE: clean

    //ez jobb
    //return output_of("git status --short")::empty // TRUE: clean

    //ez még jobb
    rl:=read_output_of("git status --short")
    line:=rl:readline
    rl:close
    return line::empty // TRUE: clean


********************************************************************************************
