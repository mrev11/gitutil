

**************************************************************************************
function output_of(cmd)

local output
local tmp:=tempfile("/tmp/","bak")
local debug:=debug("goc")

    run( cmd+" >"+tmp+" 2>&1")
    output:=memoread(tmp)
    ferase(tmp)
    
    if( !empty(debug) .and. !"g"==debug )
        ?? "--------------------------------------------------------"
        if( "c"$debug )
            callstack()
        end
        ?
    end
    if( "g"$debug )
        ?? "GITCMD:",cmd;?
    end
    if( "o"$debug )
        ?? output;?
    end

    return output


**************************************************************************************
function read_output_of(cmd)

local pp:=child(cmd) //{r,w}
local rl:=readlinedbgNew(pp[1])
local debug:=debug("gc")

    fclose(pp[2])

    if( !empty(debug) .and. !"g"==debug )
        ?? "--------------------------------------------------------"
        if( "c"$debug )
            callstack()
        end
        ?
    end
    if( "g"$debug )
        ?? "GITCMD:",cmd;?
    end

    return rl //le kell majd zárni (rl:close)



**************************************************************************************
function name_to_commitid(name)
    return commitid_of_mergebase(name,name)  //ez jobb

#ifdef NOTDEF
local rl:=read_output_of("git log -n 1 --format=oneline "+name)
local line:=rl:readline
    rl:close
    if( empty(line) .or. 41!=at(a" ",line) )
        return ""
    end
    return line[1..40]::bin2str  //40 karakteres commit-id
#endif


**************************************************************************************
function commitid_of_mergebase(name1,name2)

local rl:=read_output_of("git merge-base "+name1+" "+name2)
local line:=rl:readline
    rl:close
    if( empty(line) .or. 40>len(line) )
        return ""
    end
    return line[1..40]::bin2str  //40 karakteres commit-id


**************************************************************************************
function current_branch()
local rl:=read_output_of("git branch")
local line
    while( (line:=rl:readline)!=NIL )
        if( a"*"==line[1..1] )
            line::=strtran(bin(10),a"")
            line::=strtran(bin(13),a"")
            line::=bin2str
            line::=substr(3)::alltrim
            exit
        end
    end
    rl:close
    return line //name of current branch/NIL


**************************************************************************************
function list_of_branches(current)
local rl:=read_output_of("git branch")
local branches:={}
local line
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        line::=strtran(chr(10),"")
        line::=strtran(chr(13),"")
        if( "*"==line[1..1] )
            line::=substr(3)::alltrim
            current:=line
        else
            line::=alltrim
        end

        if( " -> "$line )
            //némelyik repóban
            //a remoteoknál vannak
            //ilyen furcsa hivatkozások
        else
            aadd(branches,line)
        end
    end
    rl:close
    return branches  //{b1,b2,...}



**************************************************************************************
function list_of_remote_branches()
local rl:=read_output_of("git branch -r")
local branches:={}
local line
    while( (line:=rl:readline)!=NIL )
        line::=bin2str
        line::=strtran(chr(10),"")
        line::=strtran(chr(13),"")
        line::=alltrim

        if( " -> "$line )
            //némelyik repóban
            //ilyen hivatkozások vannak
        else
            aadd(branches,line)
        end
    end
    rl:close
    return branches  //pl. {"develsave/devel","origin/master" }
                     // fajlsecifikaciok .git/refs/remotes/ alatt


**************************************************************************************
function config_value_of(x)
local y:=output_of("git config --get "+x)
    y::=strtran(chr(10),"")
    y::=strtran(chr(13),"")
    return y 


**************************************************************************************
