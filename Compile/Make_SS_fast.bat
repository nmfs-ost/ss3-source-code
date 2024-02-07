@echo off

@REM compiling ss.exe (safe executable) with generic path
@REM requires "Compile" directory in the same directory where
@REM the .tpl files and this .bat file sit.

cd ..

@REM deleted temporary file
del SS_functions.temp

@REM create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

@REM combine remaining files to create ss.tpl
copy/b SS_versioninfo_330opt.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss_opt.tpl"

cd Compile

if defined ADMB_HOME (
  if exist "%ADMB_HOME%\\admb.cmd" (
    @echo "-- Building ss_opt.exe with %ADMB_HOME%\admb.cmd in '%CD%' --"
    set CXX=g++
    %ADMB_HOME%\\admb.cmd -f ss_opt
    goto CHECK
  )
)

@REM check if admb.cmd is in path
for /f "tokens=*" %%i in ('where admb.cmd 2^>^&1 ^| findstr "admb.cmd"') do (
  @echo "-- Building ss_opt.exe with admb.cmd in '%CD%' --"
  set CXX=g++
  @REM admb.cmd -f ss_opt
  goto CHECK
)

@REM compile executable
for /f "tokens=*" %%i in ('where docker.exe 2^>^&1 ^| findstr "docker.exe"') do (
  @echo "-- Building ss_opt.exe with docker in '%CD%' --"
  for /f "tokens=*" %%j in ('ver ^| findstr "10.0.1"') do (
    set "ISWINDOWS10=found"
  )
  if defined ISWINDOWS10 (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb:windows-ltsc2019-winlibs -f ss_opt.tpl
  ) else (
    docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb:windows-ltsc2022-winlibs -f ss_opt.tpl
  )
  goto CHECK
)

:CHECK
if not exist ss_opt.exe (
  @echo "Error: Unable to build ss_opt.exe"
  exit /b 1
) else (
  exit /b 0
)
