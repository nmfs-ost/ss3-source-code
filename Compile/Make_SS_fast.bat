@REM compiling ss.exe (safe executable) with generic path
@REM requires "Compile" directory in the same directory where
@REM the .tpl files and this .bat file sit.

pushd ..

@REM deleted temporary file
del SS_functions.temp

@REM create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

@REM combine remaining files to create ss.tpl
copy/b SS_versioninfo_330opt.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss_opt.tpl"

@REM cd "Compile"
popd

@REM check if admb.cmd is in path
for /f "tokens=*" %%i in ('where admb.cmd 2^>^&1 ^| findstr "admb.cmd"') do (
  set "ADMB_HOME="
)

@REM compile executable
if not defined ADMB_HOME (
  @echo "-- Building ss_opt.exe with docker in '%CD%' --"
  docker run --rm --mount source=%CD%,destination=C:\compile,type=bind --workdir C:\\compile johnoel/admb:windows ss_opt.tpl
) else (
  @echo "-- Building ss_opt.exe in '%CD%' --"
  set CXX=g++
  admb -f ss_opt
)
