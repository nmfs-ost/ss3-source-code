cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del *.obj
del ss.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl SS_functions.temp
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp+SS_timevaryparm.tpl+SS_tagrecap.tpl "C:\Users\richard.methot\Documents\SS_model\Compile\ss.tpl"

set "PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\BIN\amd64_x86;C:\Program Files (x86)\MSBuild\14.0\bin\amd64;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64;%PATH%"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"
C:\ADMB_12.0_use\bin\tpl2cpp ss

pushd "%VS140COMNTOOLS%\..\..\VC" & call vcvarsall.bat amd64 & popd

cl /c /nologo /EHsc /DOPT_LIB /O2 /I. /I"C:\ADMB_12.0_use" /I"C:\ADMB_12.0_use\include" /I"C:\ADMB_12.0_use\contrib\include" /Foss_opt.obj ss.cpp

cl /Fess_opt.exe ss_opt.obj "C:\ADMB_12.0_use\lib\admb-contribo.lib" "C:\ADMB_12.0_use\lib\admbo.lib" /link

dir ss_opt.exe
