DATA_SECTION
!!// Stock Synthesis
!!// Developed by Richard Methot, NOAA Fisheries

!!//  SS_Label_Section_1.0 #DATA_SECTION

!!//  SS_Label_Info_1.1.1  #Create string with version info
!!version_info+="#V3.30.12.00-safe;_2018_08_27;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.6";
!!version_info+="#Stock Synthesis (SS) is a work of the U.S. Government and is not subject to copyright protection in the United States.";
!!version_info+="#Foreign copyrights may apply. See copyright.txt for more information.";
!!version_info2+="#_user_support_available_at:NMFS.Stock.Synthesis@noaa.gov";
!!version_info3+="#_user_info_available_at:https://vlab.ncep.noaa.gov/group/stock-synthesis";

!!//  V3.30.01.13  fix problem with transition to linear growth in Richards growth function
!!//  V3.30.04.01  05/23/2017  convert 3.24 birthseason to 3.30 settlement_event; no mandatory I/O change
!!//  V3.30.04.02  05/30/2017  fix index issue in converter for MGparm seasonal effects and for retention in fleet >1
!!//  V3.30.05.02  06/28/2017  fix issue with settlement events in spawn_season
!!//  V3.30.06.01  07/12/2017  enhance capability and control of depletion fleet
!!//  V3.30.06.02  07/25/2017  implement fcast_specify_selex to fix problem&various other format ++
!!//  V3.30.07.01  08/07/2017  augment detailed_F input; augment SPR/YPR output profile
!!//  V3.30.07.02  08/15/2017  repair age-specific K; fix growth problem if settlement age >0
!!//  V3.30.08.01  08/29/2017  fix Nfleet1 erroneous usage, except in tag parameters, I/O change in forecast
!!//  V3.30.08.02  2017-09-26  minor fixes to env_data output and to rebuild.dat output
!!//  V3.30.08.03  2017-09-29  fix error in the new code for ss_summary.sso
!!//  V3.30.08.04  2017-11-06  VLAB #40546; fix forecast recruitment error when spawn_month>1
!!//  V3.30.09.00  2017-11-17  expand 2D_AR to provide control for extrapolation to years before and after the dev range
!!//  V3.30.09.00  2017-11-20  provide controls for forecast recruitment
!!//  V3.30.10.00  2017-11-27  provide controls for bycatch fleets; mandatory I/O change if they exist
!!//  V3.30.10.00  2017-11-27  provide benchmark and forecast option to use F0.1; this is either or with F(Btgt)
!!//  V3.30.10.00  2017-11-27  clarify internal usage and output for SSB_virgin vs SSB_unfished (benchmark)
!!//  V3.30.10.00  2018-01-09  clarify output in forecast-report.sso and SPR/YPR profile
!!//  V3.30.10.01  2018-01-25  fix logic bug in calculation of settlement age 
!!//  V3.30.10.02  2018-02-02  fix problem with super year in generalized size comp
!!//  V3.30.10.02  2018-02-02  break SS_write.tpl into SS_write, SS_write_report and SS_write_ssnew
!!//  V3.30.10.02  2018-02-02  clean-up the cout's at end of run
!!//  V3.30.11.00  2018-02-27  for Richards growth, disable trap on fish shrinkage due to code interaction
!!//  V3.30.11.00  2018-02-27  add copyright disclaimer
!!//  V3.30.11.00  2018-02-27  reformat ss_summary.sso
!!//  V3.30.11.00  2018-02-27  add totbio, smrybio, and total catch biomass to end of ss_summary.sso, but no se
!!//  V3.30.11.00  2018-03-06  revise reportdetail so value of 0 omits nearly all output files
!!//  V3.30.11.00  2018-03-07  parameter specific labels for double normal selectivity
!!//  V3.30.11.00  2018-03-10  trial versions Ricker-Power spawner-recruitment
!!//  V3.30.11.00  2018-03-26  re-arrange code to allow -noest option to work
!!//  V3.30.11.00  2018-03-26  add spawner-recruitment plotting output below spawn_recr in report.sso
!!//  V3.30.11.00  2018-03-28  add output of selected estimated survey values to sdreport and show in ss_summary.sso
!!//  V3.30.11.00  2018-03-28  add output of ln(SPB) for 3 years to sdreport and show in ss_summary.sso
!!//  V3.30.11.00  2018-03-28  improve treatment of biasadjustment when first entering MCMC phase; read adjustment factor in starter
!!//  V3.30.12.00  2018-06-26   add more control rule methods
!!//  V3.30.12.00  2018-06-26   Input Change:  add new column to mean body size input to cleanly separate mean length vs mean weight
!!//  V3.30.12.00  2018-06-26   add new age selectivity non-parametric, sex-specific options #44 and #45
!!//  V3.30.12.00  2018-06-26   add new mean F for reporting to get mean without numbers weighting
!!//  V3.30.12.00  2018-06-26   improve output to Fit_Len, Fit_Age, fit_Size and include subseas info; also subseas info in compreport.sso
!!//  V3.30.12.00  2018-06-26   improve error checking on read of wtatage.ss and improve creation of wtatage.ss_new
!!//  V3.30.12.00  2018-06-26   update and clarify usage of the "-1" code for fishery sample timing
!!//  V3.30.12.00  2018-06-26   change mean forecast recruitment option to use range of years previously specified in forecast years
!!//  V3.30.12.00  2018-06-28   move dev phase and dev se from 3.24 format into 3.30 format
!!//  V3.30.12.00  2018-06-29   FIX to enable time-vary SRR parms in forecast
!!//  V3.30.12.00  2018-07-06   re_arrange get_growth2 and prep for more growth options;
!!//  V3.30.12.00  2018-07-11   enable time-varying ageing bias and error parameters
!!//  V3.30.12.00  2018-07-11   depletion_basis now includes endyear option: 0=skip; 1=rel X*SPB0; 2=rel SPBmsy; 3=rel X*SPB_styr; 4=rel X*SPB_endyr
!!//  V3.30.12.00  2018-07-13   FIX  in Richard growth
!!//  V3.30.12.00  2018-07-16   BIG FIX restore ability to mirror retention
!!//  V3.30.12.00  2018-07-16   add lambda change type 18 for initial equilibrium regime shift
!!//  V3.30.12.00  2018-07-18   add fatal warning for len selectivity mirroring of higher numbered fleet
!!//  V3.30.12.00  2018-07-18   improve implementation of softparmbounds using selparm_PH_soft()
!!//  V3.30.12.00  2018-07-20   get density-dependence working for parameters; note changed format for input
!!//  V3.30.12.00  2018-07-23   add lines in control.ss_new to improve readability of parameter lines
!!//  V3.30.12.00  2018-07-26   make time-vary R0 available in initial equilibrium year to match 3.24
!!//  V3.30.12.00  2018-07-26   improve performance of jitter when parameter nears bounds
!!//  V3.30.12.00  2018-07-26   fix reading of selex patterns 42 and 43
!!//  V3.30.12.00  2018-07-26   FIX overwriting of fecundity-at-age for benchmark when growth is time-varying
!!//  V3.30.12.00  2018-07-30   FIX offset in reporting the full spawn_recr curve
!!//  V3.30.12.00  2018-07-30   FIX re-enable time-vary growth when using Richards growth
!!//  V3.30.12.00  2018-08-01   BIG FIX when growth is time-varying, incorrect ALK could get used for benchmark selectivities
!!//  V3.30.12.00  2018-08-01   change growth within plus group back to 3.24 approach and create option to ignore plus group growth
!!//  V3.30.12.00  2018-08-10   add Bmsy/Bzero to list of derived quantities
!!//  V3.30.12.00  2018-08-10   enable display of logL for ignored length and age comp observations
!!//  V3.30.12.00  2018-08-27   add reporting of discard at age
