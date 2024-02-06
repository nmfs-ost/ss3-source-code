@echo off

::compiling ss.exe (safe executable) with generic path
::requires "Compile" directory in the same directory as the .tpl files and this .bat file

pushd ..

::deleted temporary file
del SS_functions.temp

	@@ -12,8 +16,41 @@ copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_read

::path=c:\admb;C:\rtools40\mingw64\bin;%path%

@REM cd "Compile"
popd

if defined ADMB_HOME (
  if exist "%ADMB_HOME%\\admb.cmd" (
    @echo "-- Building ss.exe with %ADMB_HOME%\admb.cmd in '%CD%' --"
    set CXX=g++
    %ADMB_HOME%\\admb.cmd ss
    goto EOF
  )
)

@REM check if admb.cmd is in path
for /f "tokens=*" %%i in ('where admb.cmd 2^>^&1 ^| findstr "admb.cmd"') do (
  @echo "-- Building ss.exe with admb.cmd in '%CD%' --"
  set CXX=g++
  admb.cmd ss
  goto EOF
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
  goto EOF
)

@echo "Error: Unable to build ss.exe"
exit /b 1

:EOF