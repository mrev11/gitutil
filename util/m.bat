@echo off 
call bapp_w32_.bat @parfilew.bld
copy obj%CCCBIN%\*.lib  %CCCDIR%\usr\lib\%CCCBIN%