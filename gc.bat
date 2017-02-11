@echo off
: torli a .gitignored fajlokat
: vegrehajtja .git/local/profile.bat-ot

git clean -fXd  2>&1 >NUL

if not exist .git/local/profile.bat goto endprofile
    call .git/local/profile.bat
:endprofile


