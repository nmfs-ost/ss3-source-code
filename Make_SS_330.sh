#!/bin/sh

cd vlab/stock-synthesis

if [ ! -d SS330 ]; then
    mkdir SS330
fi

if [ -f SS_functions.temp ]; then
    rm SS_functions.temp
fi

cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl > SS_functions.temp
cat SS_versioninfo_330safe.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp SS_timevaryparm.tpl > SS330/ss.tpl

cd SS330
admb ss

