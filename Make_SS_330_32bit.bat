cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del *.obj
del ss_32bit.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "C:\Users\richard.methot\Documents\SS_model\Compile\ss.tpl"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"

pushd "%VS140COMNTOOLS%\..\..\VC" & call vcvarsall.bat x86 & popd
set "PATH=%CD%\bin;%CD%\utilities;%PATH%"

C:\ADMB32\bin\TPL2CPP.EXE ss

cl /c /nologo /EHsc /O2 /I. /I"C:\ADMB32" /I"C:\ADMB32\contrib\include" /I"C:\ADMB32\include" /Foss.obj ss.cpp

cl /Fess_32bit.exe ss.obj "C:\ADMB32\lib\admb-contrib.lib" /link

dir ss_32bit.exe
