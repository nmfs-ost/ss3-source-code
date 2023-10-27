# The admb script should be included in the system PATH. If not, the
# path to the script can be manually set (See MY_ADMB_HOME below).
#
# Usage:
#   ./stock-synthesis/$ make

# Uncomment MY_ADMB_HOME to manually set path to admb script
# and ignore system enviroment PATH.
# Note: Need to add directory character '/' at the end.
# MY_ADMB_HOME=~/admb-main/

# Uncomment the variables below for static and/or debugging builds.
# STATIC_BUILD= -p
# DEBUG= -g

export CXXFLAGS=-Wall -Wextra

all: clean
	$(MAKE) ss
	$(MAKE) ss_opt

docker:
	$(MAKE) USE_DOCKER=yes all

ss: ss.tpl
ifdef USE_DOCKER
	chmod -R 777 $(CURDIR)
	docker run --rm --volume $(CURDIR):/workdir/ss:rw --workdir /workdir/ss johnoel/admb:linux ss.tpl
else
	$(MY_ADMB_HOME)admb $(DEBUG)$(STATIC_BUILD) ss.tpl
endif

ss_opt: ss_opt.tpl
ifdef USE_DOCKER
	docker run --rm --volume $(CURDIR):/workdir/ss_opt:rw --workdir /workdir/ss_opt johnoel/admb:linux ss_opt.tpl
else
	$(MY_ADMB_HOME)admb -f $(DEBUG)$(STATIC_BUILD) ss_opt.tpl
endif

ss.tpl: SS_functions.temp
	cat SS_versioninfo_330safe.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > ss.tpl

ss_opt.tpl: SS_functions.temp
	cat SS_versioninfo_330opt.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > ss_opt.tpl

SS_functions.temp:
	cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp

clean:
	@rm -vf ss
	@rm -vf ss_opt
	@rm -vf ss.tpl
	@rm -vf ss_opt.tpl
	@rm -vf SS_functions.temp
	@rm -vf ss.cpp
	@rm -vf ss.htp
	@rm -vf ss.obj
	@rm -vf ss_opt.cpp
	@rm -vf ss_opt.htp
	@rm -vf ss_opt.obj
