@echo off
rem file: pretty_tpl.bat
rem 
rem prettify tpl code by running through clang-format
rem and then tpl-format (to correct issues).
rem this assumes presence of clang-format.exe, 
rem tpl-format.exe, and the file .clang-format
rem
rem if using LOCAL_CALCS/END_CALCS, clang-format can
rem only work within those sections. Use // clang-format on
rem to turn it on after a LOCAL_CALCS and // clang-format off
rem to turn it off before END_CALCS for normal tpl code.
rem (Also place a // clang-format off at the beginning of the code).
rem 
rem usage: pretty_tpl filename 
rem
echo formatting file %1
clang-format -i %1
tpl-format %1
rem 
rem and that's it!
