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
	$(MAKE) ss3
	$(MAKE) ss3_opt

docker:
	chmod -R 777 $(CURDIR)
	$(MAKE) USE_DOCKER=yes all

ss3: ss3.tpl
ifdef USE_DOCKER
  ifeq ($(OS),Windows_NT)
	docker run --rm --volume $(CURDIR):C:\\workdir\\ss --workdir C:\\workdir\\ss johnoel/admb:windows-ltsc2022-winlibs ss3.tpl
  else
	docker run --rm --volume $(CURDIR):/workdir/ss:rw --workdir /workdir/ss johnoel/admb:linux ss3.tpl
  endif
else
	$(MY_ADMB_HOME)admb $(DEBUG)$(STATIC_BUILD) ss3.tpl
endif

ss3_opt: ss3_opt.tpl
ifdef USE_DOCKER
  ifeq ($(OS),Windows_NT)
	docker run --rm --volume $(CURDIR):C:\\workdir\\ss_opt --workdir C:\\workdir\\ss_opt johnoel/admb:windows-ltsc2022-winlibs ss3_opt.tpl
  else
	docker run --rm --volume $(CURDIR):/workdir/ss_opt:rw --workdir /workdir/ss_opt johnoel/admb:linux ss3_opt.tpl
  endif
else
	$(MY_ADMB_HOME)admb -f $(DEBUG)$(STATIC_BUILD) ss3_opt.tpl
endif

ss3.tpl: SS_functions.temp
	cat SS_versioninfo_330safe.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > ss3.tpl

ss3_opt.tpl: SS_functions.temp
	cat SS_versioninfo_330opt.tpl SS_readstarter.tpl SS_readdata_330.tpl SS_readcontrol_330.tpl SS_param.tpl SS_prelim.tpl SS_global.tpl SS_proced.tpl SS_functions.temp > ss3_opt.tpl

SS_functions.temp:
	cat SS_biofxn.tpl SS_miscfxn.tpl SS_selex.tpl SS_popdyn.tpl SS_recruit.tpl SS_benchfore.tpl SS_expval.tpl SS_objfunc.tpl SS_write.tpl SS_write_ssnew.tpl SS_write_report.tpl SS_ALK.tpl SS_timevaryparm.tpl SS_tagrecap.tpl > SS_functions.temp

clean:
	@rm -vf ss3
	@rm -vf ss3_opt
	@rm -vf ss3.tpl
	@rm -vf ss3_opt.tpl
	@rm -vf SS_functions.temp
	@rm -vf ss3.cpp
	@rm -vf ss3.htp
	@rm -vf ss3.obj
	@rm -vf ss3_opt.cpp
	@rm -vf ss3_opt.htp
	@rm -vf ss3_opt.obj
