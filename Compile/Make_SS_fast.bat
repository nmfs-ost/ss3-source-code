REM compiling ss.exe (safe executable) with generic path
REM requires "Compile" directory in the same directory where
REM the .tpl files and this .bat file sit.

cd ..
REM deleted temporary file
del SS_functions.temp

REM create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

REM combine remaining files to create ss.tpl
copy/b SS_versioninfo_330opt.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss_opt.tpl"

REM compile executable
cd "Compile"
set CXX=g++
REM admb -f ss_opt

docker run --rm --volume %CD%:\ss3-source-code\Compile --workdir \ss3-source-code\Compile johnoel/admb:windows -f ss_opt.tpl
REM docker run --rm --volume %CD%:\ss3-source-code\Compile --workdir \ss3-source-code\Compile johnoel/admb:windows -f ss_opt.tpl