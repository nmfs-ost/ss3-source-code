cd "C:\Users\richard.methot\Documents\SS_model\Trans_324_330"
del ss_trans.exe

cd "C:\Users\richard.methot\Documents\SS_model\Compile"
del *.obj
del ss_trans.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_ALK.tpl SS_functions.temp
copy/b SS_versioninfo_330trans.tpl+SS_readstarter.tpl+SS_readdata_324.tpl+SS_readcontrol_324.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_timevaryparm.tpl+SS_functions.temp "C:\Users\richard.methot\Documents\SS_model\Compile\SS3_3.tpl"
copy Make_SS_transition.bat "C:\Users\richard.methot\Documents\SS_model\Compile"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"

TPL2CPP.EXE ss3_3
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_amd64

cl /c /nologo /EHsc /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3_3.obj  ss3_3.cpp
cl /Fess_trans.exe ss3_3.obj "c:\ADMB\lib\admb-contrib.lib" "c:\ADMB\lib\admb.lib" /link

copy SS3_3.* "C:\Users\richard.methot\Documents\SS_model\Trans_324_330"
copy ss_trans.exe "C:\Users\richard.methot\Documents\SS_model\Trans_324_330"
cd "C:\Users\richard.methot\Documents\SS_model\Trans_324_330"
dir *.exe
