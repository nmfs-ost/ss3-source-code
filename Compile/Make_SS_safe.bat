::compiling ss.exe (safe executable) with generic path
::requires "Compile" directory in the same directory as the .tpl files and this .bat file
cd ..
::deleted temporary file
del SS_functions.temp

::create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

::combine remaining files to create ss3.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss3.tpl"

::path=c:\admb;C:\rtools40\mingw64\bin;%path%

cd "Compile"
::set CXX=cl
set CXX=g++

admb ss3
