@echo off

set TARGET=%USERPROFILE%\bin

if not exist %TARGET% md %TARGET%

copy   gitnav\gitref.exe                    %TARGET%
copy   gitnav\gitview.exe                   %TARGET%
copy   gitnav\gitfollow.exe                 %TARGET%
copy   gitnav\gitstat.exe                   %TARGET%
copy   gitnav\gitnav.exe                    %TARGET%
copy   gitdate\gitdate0.exe                 %TARGET%
copy   gitdate\gitdate.exe                  %TARGET%
copy   firstpar\firstpar.exe                %TARGET%
copy   filetime\filetime-save.exe           %TARGET%
copy   filetime\filetime-restore.exe        %TARGET%
copy   gitfind\gitfind.exe                  %TARGET%

