@echo off

::compiling ss.exe (safe executable) with generic path
::requires "Compile" directory in the same directory as the .tpl files and this .bat file

cd ..

::deleted temporary file
del SS_functions.temp

::create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

::combine remaining files to create ss3.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss3.tpl"
::combine remaining files to create ss3.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss3.tpl"

::path=c:\admb;C:\rtools40\mingw64\bin;%path%

cd Compile

if defined ADMB_HOME (
  if exist "%ADMB_HOME%\\admb.cmd" (
    @echo "-- Building ss3.exe with %ADMB_HOME%\admb.cmd in '%CD%' --"
    set CXX=g++
    %ADMB_HOME%\\admb.cmd ss3
    goto CHECK
  )
)

@REM check if admb.cmd is in path
for /f "tokens=*" %%i in ('where admb.cmd 2^>^&1 ^| findstr "admb.cmd"') do (
  @echo "-- Building ss3.exe with admb.cmd in '%CD%' --"
  set CXX=g++
  admb ss3.tpl
  goto CHECK
)

@REM compile executable
for /f "tokens=*" %%i in ('where docker.exe 2^>^&1 ^| findstr "docker.exe"') do (
  @echo "-- Building ss3.exe with docker in '%CD%' --"
  for /f "tokens=*" %%j in ('ver ^| findstr "10.0.1"') do (
    set "ISWINDOWS10=found"
  )
  if defined ISWINDOWS10 (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb-13.2:windows10 ss3.tpl
  ) else (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb-13.2:windows ss3.tpl
  )
  goto CHECK
)

:CHECK
if not exist ss3.exe (
  @echo "Error: Unable to build ss3.exe"
  exit /b 1
)
