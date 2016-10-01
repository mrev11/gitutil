@echo off

:set GITDEBUG=go
:g: git commands
:o: output of git commands
:c: callstack when invoking git commands

set OREF_SIZE=500000
set CCCTERM_SIZE=120x32
:set CCCTERM_INHERIT=yes

gitnav.exe %1 %2 %3 %4 | tee log-gitnav

