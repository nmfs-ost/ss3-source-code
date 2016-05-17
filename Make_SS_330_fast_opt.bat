cd "C:\Users\richard.methot\Documents\SS_model\Test_Model"
del ss_opt.exe

cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del *.obj
del ss_opt.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_ALK.tpl SS_functions.temp
copy/b SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp+SS_timevaryparm.tpl "C:\Users\richard.methot\Documents\SS_model\Compile\SS3_3.tpl"
copy Make_SS_330_fast_opt.bat "C:\Users\richard.methot\Documents\SS_model\Compile"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"

TPL2CPP.EXE ss3_3
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_amd64

REM  For optimize  add /O2
cl /c /nologo /EHsc /DOPT_LIB /O2 /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3_3.obj  ss3_3.cpp 
cl /Fess_opt.exe ss3_3.obj "c:\ADMB\lib\admb-contribo.lib" "c:\ADMB\lib\admbo.lib" /link

copy SS3_3.* "C:\Users\richard.methot\Documents\SS_model\Test_Model"
copy ss_opt.exe "C:\Users\richard.methot\Documents\SS_model\Test_Model"
cd "C:\Users\richard.methot\Documents\SS_model\Test_Model"
dir *.exe


