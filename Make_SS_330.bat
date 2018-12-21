cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del *.obj
del ss.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "C:\Users\richard.methot\Documents\SS_model\Compile\ss.tpl"

set "PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\BIN\amd64_x86;C:\Program Files (x86)\MSBuild\14.0\bin\amd64;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64;%PATH%"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"
C:\ADMB64\bin\tpl2cpp ss

pushd "%VS140COMNTOOLS%\..\..\VC" & call vcvarsall.bat amd64 & popd

cl /c /nologo /EHsc /O2 /I. /I"C:\ADMB64" /I"C:\ADMB64\include" /I"C:\ADMB64\contrib\include" /Foss.obj ss.cpp

cl /Fess.exe ss.obj "C:\ADMB64\lib\admb-contrib.lib" /link

dir ss.exe
