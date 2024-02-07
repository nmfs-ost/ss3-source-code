@echo off

::compiling ss.exe (safe executable) with generic path
::requires "Compile" directory in the same directory as the .tpl files and this .bat file

cd ..

::deleted temporary file
del SS_functions.temp

::create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

::combine remaining files to create ss.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss.tpl"

::path=c:\admb;C:\rtools40\mingw64\bin;%path%

cd Compile

if defined ADMB_HOME (
  if exist "%ADMB_HOME%\\admb.cmd" (
    @echo "-- Building ss.exe with %ADMB_HOME%\admb.cmd in '%CD%' --"
    set CXX=g++
    %ADMB_HOME%\\admb.cmd ss
    goto CHECK
  )
)

@REM check if admb.cmd is in path
for /f "tokens=*" %%i in ('where admb.cmd 2^>^&1 ^| findstr "admb.cmd"') do (
  @echo "-- Building ss.exe with admb.cmd in '%CD%' --"
  set CXX=g++
  admb ss.tpl
  exit /b 0
)

@REM compile executable
for /f "tokens=*" %%i in ('where docker.exe 2^>^&1 ^| findstr "docker.exe"') do (
  @echo "-- Building ss.exe with docker in '%CD%' --"
  for /f "tokens=*" %%j in ('ver ^| findstr "10.0.1"') do (
    set "ISWINDOWS10=found"
  )
  if defined ISWINDOWS10 (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb:windows-ltsc2019-winlibs ss.tpl
  ) else (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb:windows-ltsc2022-winlibs ss.tpl
  )
  goto CHECK
)

:CHECK
if not exist ss.exe (
  @echo "Error: Unable to build ss.exe"
  exit /b 1
) else (
  exit /b 0
)
)
