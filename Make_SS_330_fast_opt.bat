cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del ss_opt.*

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl SS_functions.temp
copy/b SS_versioninfo_330opt.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp+SS_timevaryparm.tpl "C:\Users\richard.methot\Documents\SS_model\Compile\ss.tpl"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"

pushd "%VS140COMNTOOLS%\..\..\VC" & call vcvarsall.bat amd64 & popd
set "PATH=%CD%\bin;%CD%\utilities;%PATH%"

C:\ADMB64\bin\TPL2CPP.EXE ss

REM  For optimize  add /O2
cl /c /nologo /EHsc /DOPT_LIB /O2 /I. /I"c:\ADMB64" /I"c:\ADMB64\include" /I"c:\ADMB64\contrib\include" /Foss_opt.obj  ss.cpp 
cl /Fess_opt.exe ss_opt.obj "c:\ADMB64\lib\admb-contribo.lib" "c:\ADMB64\lib\admbo.lib" /link

dir ss_opt.exe


