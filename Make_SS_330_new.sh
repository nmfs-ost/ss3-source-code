#!/bin/sh

# want help?
function usage()
{
  echo "Call this script as follows:"
  echo "  ./Make_SS_330_new.sh [-s source_dir] [-b build_dir] [-a admb_dir] [-o | -t] [-h]"
  echo " (Directories may be relative or absolute)"
}

function build_safe()
{
echo "-- building ss in '$BUILD_DIR' "
# concatenate all tpl files to a single file
cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp
cat SS_versioninfo_330safe.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > $BUILD_DIR/ss.tpl

cd $BUILD_DIR
admb ss
}

function build_opt()
{
echo "-- building ss_opt in '$BUILD_DIR' "
# concatenate all tpl files to a single filecat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp
cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp
cat SS_versioninfo_330opt.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > $BUILD_DIR/ss_opt.tpl

cd $BUILD_DIR
admb -f ss_opt
}

function build_trans()
{
echo "-- building ss_trans in '$BUILD_DIR' "
# concatenate all tpl files to a single filecat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp
cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp
cat SS_versioninfo_330trans.tpl SS_readstarter.tpl SS_readdata_324.tpl SS_readcontrol_324.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > $BUILD_DIR/ss_trans.tpl

cd $BUILD_DIR
admb ss_trans
}

# default directories
SRC_DIR=vlab/stock-synthesis
BUILD_DIR=SS330
TYPE=safe

while [ "$1" != "" ]; do
    case $1 in
         # check for new source directory
        -s | --source )  shift
                         SRC_DIR=$1
                         ;;
         # check for new build directory
        -b | --build )   shift
                         BUILD_DIR=$1
                         ;;
         # check for ADMB directory and set
        -a | --admb )    shift
                         ADMB_HOME=$1
                         export ADMB_HOME
                         PATH=$ADMB_HOME:$PATH
                         ;;
        -h | --help )    usage
                         exit
                         ;;
        -o | --opt )     TYPE=opt
                         ;;
        -t | --trans )   TYPE=trans
                         ;;
         * )             usage
                         exit 1
    esac
    shift
done

cd $SRC_DIR

# delete the temp file if it exists
if [ -f SS_functions.temp ]; then
    rm SS_functions.temp
fi

case $TYPE in
    trans )   build_trans
              ;;
    opt )     build_opt
              ;;
    * )       build_safe
esac

exit
