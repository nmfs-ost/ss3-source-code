ADMB_HOME=~/admb-main/

#STATIC_BUILD= -p
#DEBUG= -g
export CXXFLAGS=-Wall -Wextra

all: clean
	$(MAKE) ss
	$(MAKE) ss_opt

ss: ss.tpl
	$(ADMB_HOME)admb$(DEBUG)$(STATIC_BUILD) ss.tpl

ss_opt: ss_opt.tpl
	$(ADMB_HOME)admb -f$(DEBUG)$(STATIC_BUILD) ss_opt.tpl

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
