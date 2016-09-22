
//Csinál egy git repót,
//amiben a gitnav-val lehet dolgozni.
//
//A plusz dolgok:
//
//  CHANGELOG_$USER
//  .FILETIME_$USER
//  scriptek: gc,gn,gv,gr,ftr,fts 
//  .gitignore
//  .git/hooks/post-checkout
//  .git/local/*

***************************************************************************************
function create_repo()

local user:=getenv("USER")
local dep:=0

    ? "These programs will be searched in the path:"
    dep+=dep("filetime-save.exe")
    dep+=dep("filetime-restore.exe")
    dep+=dep("firstpar.exe")
    dep+=dep("gitnav.exe")
    dep+=dep("gitref.exe")
    dep+=dep("gitview.exe")
    if(dep>0)
        ? "unresolved dependencies:",str(dep,2)
    end
    ?
    ?

    run("git init")
    memowrit("CHANGELOG_"+user,"initial import")    
    memowrit("commit-message","initial import")    
    memowrit(".gitignore",gitignore())
    memowrit(".git/hooks/post-checkout",post_checkout())
    chmod(".git/hooks/post-checkout",0b111101101)//755

    dirmake( ".git/local")
    memowrit(".git/local/profile",profile())
    memowrit(".git/local/g-log",g_log())
    memowrit(".git/local/g-log1",g_log1())
    memowrit(".git/local/g-log-graph",g_log_graph())
    memowrit(".git/local/g-commit",g_commit())
    memowrit(".git/local/g-merge",g_merge())
    memowrit(".git/local/g-initial-upload",g_initial_upload())

    memowrit("gc",script_gc());   chmod("gc",0b111101101)//755
    memowrit("gn",script_gn());   chmod("gn",0b111101101)//755
    memowrit("gr",script_gr());   chmod("gr",0b111101101)//755
    memowrit("gv",script_gv());   chmod("gv",0b111101101)//755
    memowrit("fts",script_fts()); chmod("fts",0b111101101)//755
    memowrit("ftr",script_ftr()); chmod("ftr",0b111101101)//755

    run("filetime-save.exe")    

    //run("git add --all")
    run("git add "+"CHANGELOG_"+user) //epp csak ne kegyenures
    run("git commit -F commit-message")
    //quit


***************************************************************************************
static function dep(dep)
local spec:=output_of("which "+dep)
    spec::=strtran(chr(10),"")
    spec::=strtran(chr(13),"")
    ? ' ',dep,'->',spec
    return if(empty(spec),1,0)


***************************************************************************************
//script szovegek
***************************************************************************************
static function profile()
local x:=<<XX>>
for GSCRIPT in .git/local/g-*; do
    if ! [ -f $(basename $GSCRIPT) ]; then
        ln -s $GSCRIPT .
    fi
done
<<XX>>
    return x


***************************************************************************************
static function gitignore() 
local x:=<<XX>>
*.bak
*~
*.o
*.obj
*.a
*.lib
*.so
*.class
*.jar

compopt
outcpp
rsplib
rsplink
gccver.opt

*.exe
objlin/
ppo/
error
error--*
log-*

commit-message
g-*
/*.savex
<<XX>>
    return x

***************************************************************************************
static function post_checkout()
local x:=<<XX>>#!/bin/bash
echo 'Invoked post-checkout'
filetime-restore.exe
<<XX>>
    return x

***************************************************************************************
static function  g_log()
local x:=<<XX>>#!/bin/bash
git log  --date=iso-local
<<XX>>
    return x

***************************************************************************************
static function g_log1()
local x:=<<XX>>#!/bin/bash
git log --pretty=oneline  --abbrev-commit 
<<XX>>
    return x


***************************************************************************************
static function g_log_graph()
local x:=<<XX>>#!/bin/bash
git log --oneline --decorate --graph --all
<<XX>>
    return x


***************************************************************************************
static function g_commit()
local x:=<<XX>>#!/bin/bash
if ! test -x .git/hooks/post-checkout; then
/bin/cat << 'EOF' >.git/hooks/post-checkout
#!/bin/bash
echo 'Invoked post-checkout'
filetime-restore.exe
EOF
chmod 755 .git/hooks/post-checkout
fi


#minden változást commitol
#git add --all

filetime-save.exe
git add .FILETIME_$USER
firstpar.exe  CHANGELOG_$USER >commit-message
git commit -F commit-message
rm commit-message
<<XX>>
    return x


***************************************************************************************
static function g_merge()
local x:=<<XX>>#!/bin/bash

# merge-elni úgy kell, hogy
#   commitoljuk a devel ágat (git status üreset ad)
#   ráállunk a master ágra (git branch master )

 git merge devel

# ez beolvasztja develt a masterba
# ellenorizni kell a conflictokat
# egy conflict így néz ki:
#
#<<<<<<< HEAD
#    master version
#    master version
#    master version
#=======
#    devel version
#    devel version
#    devel version
#>>>>>>> devel
#
# ki kell javitani a forrásokat a conflictoknál
# és újra commitolni, a .FILETIME_* fájlok esetleges
# conflictjai nem érdekesek (de commitolni kell)
<<XX>>
    return x


***************************************************************************************
static function g_initial_upload()
local x:=<<XX>>#!/bin/bash
set -x

REMOTE_HOST=comfirm.hu
REMOTE_PATH=/opt/git/private/gitutil.git
REMOTE_URL=ssh://git@$REMOTE_HOST$REMOTE_PATH


ssh git@$REMOTE_HOST "git init --bare $REMOTE_PATH"


# A lokális repóban létrehozzuk az "origin" remote definíciót,
# ha ez megvan, akkor az URL helyett a rövid remote nevet, esetünkben
# az "origin-t" használhatjuk. Több remote is lehet, és akármilyen neve 
# lehet a remoteoknak. A lényeg, hogy egy remote meghatároz egy URL-t.

git remote add  origin  $REMOTE_URL

git config branch.master.remote origin
git config branch.master.merge  refs/heads/master


# Most még nincs feltöltve semmi, de megvannak a default
# paraméterek, tehát a pull/push egyeszerűen működnek:

git push
git pull
<<XX>>
    return x

***************************************************************************************
static function script_gc()
local x:=<<XX>>#!/bin/bash

#1) törli az összes .gitignored fájlt
#2) átlinkeli az .git/local-ban levő scripteket
#
#
# Az a koncepció, .git/local-ban egyéni scriptek vannak
# amelyek mind ignoráltak, ezért  git clean -fXd törli őket
# az objectekkel es exekkel együtt, de csak a gyökérben
# levő linkjüket, a .git/local-ban levő tényleges fájlt nem.
# A második lépésben aztán újra belinkelődnek a gyökérbe.

# Illetve általánosabb: végrehajtja .git/local/profile-t,
# ami azt csinál, amit akar, ha akar linkel.

git clean -fXd  2>&1 >/dev/null

if [ -f .git/local/profile  ];then
   . .git/local/profile
fi


<<XX>>
    return x

***************************************************************************************
static function script_gn()
local x:=<<XX>>#!/bin/bash
#set -x

#export GITDEBUG=goc
#g: git commands
#o: output of git commands
#c: callstack when invoking git commands

export OREF_SIZE=500000
export CCCTERM_SIZE=120x40
#export CCCTERM_INHERIT=yes

exec gitnav.exe "$@" #>log-gitnav

<<XX>>
    return x

***************************************************************************************
static function script_gr()
local x:=<<XX>>#!/bin/bash
#set -x

#export GITDEBUG=goc
#g: git commands
#o: output of git commands
#c: callstack when invoking git commands

export CCCTERM_SIZE=120x40

exec gitref.exe
<<XX>>
    return x


***************************************************************************************
static function script_gv()
local x:=<<XX>>#!/bin/bash
#git diff viewer

#export GITDEBUG=goc
#g: git commands
#o: output of git commands
#c: callstack when invoking git commands

exec gitview.exe  "$@"
<<XX>>
    return x

***************************************************************************************
static function script_fts()
local x:=<<XX>>#!/bin/bash
export OREF_SIZE=500000
exec filetime-save.exe  "$@"
<<XX>>
    return x

***************************************************************************************
static function script_ftr()
local x:=<<XX>>#!/bin/bash
export OREF_SIZE=100000
exec filetime-restore.exe
<<XX>>
    return x


***************************************************************************************


