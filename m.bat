@echo off

pushd util      &   call m.bat & popd
pushd filetime  &   call m.bat & popd
pushd firstpar  &   call m.bat & popd
pushd gitdate   &   call m.bat & popd
pushd gitfind   &   call m.bat & popd
pushd gitnav    &   call m.bat & popd

call install.bat
