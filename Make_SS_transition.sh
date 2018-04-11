#!/bin/sh

cd vlab/stock-synthesis

if [ ! -d SS330_tr ]; then
    mkdir SS330_tr
fi

if [ -f SS_functions.temp ]; then
    rm SS_functions.temp
fi

cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl > SS_functions.temp
cat SS_versioninfo_330trans.tpl SS_readstarter.tpl SS_readdata_324.tpl SS_readcontrol_324.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_timevaryparm.tpl SS_functions.temp > SS330_tr/ss_trans.tpl

cd SS330_tr
admb ss_trans

