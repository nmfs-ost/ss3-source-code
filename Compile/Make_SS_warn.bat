
::compiling ss.exe (safe executable) with generic path
::requires "Compile" directory in the same directory as the .tpl files and this .bat file

cd ..

::deleted temporary file
del SS_functions.temp

::create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

::combine remaining files to create ss3.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss3.tpl"

::path=c:\admb;C:\rtools40\mingw64\bin;%path%

cd Compile

if exist ss3.exe (
  if exist ss3_old.exe (
    del ss3old.exe
  )
  ren ss3.exe ss3_old.exe
)

tpl2cpp ss3

g++ -c -std=c++14 -O2 -D_FILE_OFFSET_BITS=64  -DUSE_ADMB_CONTRIBS -D_USE_MATH_DEFINES -I. -I"C:\ADMB-13.1\include" -I"C:\ADMB-13.1\include\contrib" -Wall -Wextra -o ss3.obj ss3.cpp

g++ -static -o ss3.exe ss3.obj "C:\ADMB-13.1\lib\libadmb-contrib-mingw64-g++8.a"

dir *.exe
