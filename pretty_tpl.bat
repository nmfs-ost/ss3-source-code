@echo off
rem file: pretty_tpl.bat
rem 
rem prettify tpl code by running through clang-format
rem and then tpl-format (to correct issues).
rem this assumes presence of clang-format.exe, 
rem tpl-format.exe, and the file .clang-format
rem 
rem use: pretty_tpl filename 
rem
echo formatting file %1
clang-format -i %1
tpl-format %1
rem 
rem and that's it!
