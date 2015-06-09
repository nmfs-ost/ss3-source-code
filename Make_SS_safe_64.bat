REM @echo off
REM copy "C:\Users\Richard.Methot\Documents\GitHub\StockSynthesis_3.3\ss3trial.tpl" "C:\Users\richard.methot\Documents\SS_model\Test_Model"
REM cd "C:\Users\richard.methot\Documents\SS_model\Test_Model"
cd "C:\Users\richard.methot\Documents\SS_model\SS_code"
del SS_functions.tpl
del SS3trial.tpl
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_ALK.tpl SS_functions.tpl
copy/b SS_readdata.tpl+SS_readcontrol.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.tpl SS3trial.tpl

del ss3.exe
del C:\SS_model\Test_Model\ss3.exe
del ss3trial.obj

@echo on
TPL2CPP.EXE ss3trial
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_amd64

REM safe, no opt
REM cl -c /EHsc -DUSE_LAPLACE -DWIN32 -DSAFE_ALL  -D__MSVC32__=8 /DEBUG -I. -I"%ADMB64_HOME%"\include -I"%ADMB64_HOME%"\contrib\include -I"C:\Program Files\Microsoft SDKs\Windows\v7.1\include" -I"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include" ss3trial.cpp

cl /c /nologo /EHsc /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3trial.obj  ss3trial.cpp

REM for fast mode
REM  cl /c /nologo /EHsc /DOPT_LIB /I. /I"c:\ADMB\include" /I"c:\ADMB\contrib\include" /Foss3trial.obj  ss3trial.cpp

REM  cl  ss3trial.obj admb.lib "%ADMB64_HOME%"\contrib\lib\contrib.lib /link /libpath:"%ADMB64_HOME%"\lib /libpath:"C:\Program Files\Microsoft SDKs\Windows\v7.1\lib\x64" /libpath:"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib\amd64"
cl /Fess3trial.exe ss3trial.obj "c:\ADMB\lib\admb-contrib.lib" /link

REM for fast mode
REM cl /Fess3trial.exe ss3trial.obj "c:\ADMB\lib\admb-contribo.lib" /link

copy ss3trial.exe C:\SS_model\Test_Model\ss3.exe
REM optimized
REM cl -c /EHsc -DUSE_LAPLACE -DWIN32 -DOPT_LIB -D__MSVC32__=8 -I. -I"%ADMB64_HOME%"\include -I"%ADMB64_HOME%"\contrib\include -I"C:\Program Files\Microsoft SDKs\Windows\v7.1\include" -I"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include" ss3trial.cpp

REM cl  ss3trial.obj admbo.lib "%ADMB64_HOME%"\contrib\lib\contribo.lib /link /libpath:"%ADMB64_HOME%"\lib /libpath:"C:\Program Files\Microsoft SDKs\Windows\v7.1\lib\x64" /libpath:"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib\amd64"

REM copy ss3trial.exe ss3_opt.exe

dir *.exe
