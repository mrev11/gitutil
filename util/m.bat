@echo off 
call bapp_w32_.bat -lccc%CCCVER%_gitutil  @parfile.bld
copy obj%CCCBIN%\*.lib  %CCCDIR%\usr\lib\%CCCBIN%