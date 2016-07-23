
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
local pipe:=child("git status") //{pr,pw}
local result:=.f.

    fclose(pipe[2])
    rl:=readlineNew(pipe[1])
    while NIL!=(line:=rl:readline)
        if( a'nothing to commit, working directory clean' $ line )
            result:=.t.
        end
    end
    fclose(pipe[1])

    return result // TRUE: clean



********************************************************************************************
