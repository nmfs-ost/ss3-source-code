cd "C:\Users\richard.methot\Documents\SS_model\Test_Model"
del *.exe

cd "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3"
del SS_functions.temp
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_ALK.tpl SS_functions.temp
copy/b SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "C:\Users\richard.methot\Documents\SS_model\Compile\SS3_3.tpl"
copy Make_SS_330.bat "C:\Users\richard.methot\Documents\SS_model\Compile"
cd "C:\Users\richard.methot\Documents\SS_model\Compile"

TPL2CPP.EXE ss3_3
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_amd64
cl /c /nologo /EHsc /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3_3.obj  ss3_3.cpp
cl /Fess3.exe ss3_3.obj "c:\ADMB\lib\admb-contrib.lib" /link
copy SS3_3.* "C:\Users\richard.methot\Documents\SS_model\Test_Model"
copy SS3.exe "C:\Users\richard.methot\Documents\SS_model\Test_Model"
cd "C:\Users\richard.methot\Documents\SS_model\Test_Model"
dir *.exe

REM safe, no opt
REM cl -c /EHsc -DUSE_LAPLACE -DWIN32 -DSAFE_ALL  -D__MSVC32__=8 /DEBUG -I. -I"%ADMB64_HOME%"\include -I"%ADMB64_HOME%"\contrib\include -I"C:\Program Files\Microsoft SDKs\Windows\v7.1\include" -I"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include" ss3_3.cpp


REM for fast mode
REM  cl /c /nologo /EHsc /DOPT_LIB /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3_3.obj  ss3_3.cpp

REM  cl  ss3_3.obj admb.lib "%ADMB64_HOME%"\contrib\lib\contrib.lib /link /libpath:"%ADMB64_HOME%"\lib /libpath:"C:\Program Files\Microsoft SDKs\Windows\v7.1\lib\x64" /libpath:"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib\amd64"

REM for fast mode
REM cl /Fess3.exe ss3_3.obj "c:\ADMB\lib\admb-contribo.lib" /link

REM optimized
REM cl -c /EHsc -DUSE_LAPLACE -DWIN32 -DOPT_LIB -D__MSVC32__=8 -I. -I"%ADMB64_HOME%"\include -I"%ADMB64_HOME%"\contrib\include -I"C:\Program Files\Microsoft SDKs\Windows\v7.1\include" -I"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include" ss3trial.cpp

REM cl  ss3trial.obj admbo.lib "%ADMB64_HOME%"\contrib\lib\contribo.lib /link /libpath:"%ADMB64_HOME%"\lib /libpath:"C:\Program Files\Microsoft SDKs\Windows\v7.1\lib\x64" /libpath:"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib\amd64"

