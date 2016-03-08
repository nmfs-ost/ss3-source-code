#V3.30a
#C growth parameters are estimated
#C spawner-recruitment bias adjustment Not tuned For optimality
#_data_and_control_files: simple_disc.dat // simple_lendisc.ctl
#_SS-V3.30a-safe;_07_20_2015;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.1
1  #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond  1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#
1 # recr_dist_method for parameters:  1=like 3.24; 2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=none when N_GP*Nsettle*pop==1
1 # Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments
0 # year_x_area_x_settlement_event interaction requested (only for recr_dist_method=1)
#GPat month  area (for each settlement assignment)
 1 1 1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
0 #_Nblock_Patterns
#_Cond 0 #_blocks_per_pattern
# begin and end years of blocks
#
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
  #_no additional input for selected M option; read 1P per morph
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
0 #_Growth_Age_for_L1
25 #_Growth_Age_for_L2 (999 to use as Linf)
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=read fec and wt from wtatage.ss
#_placeholder for empirical age-maturity by growth pattern
1 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
2 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#_growth_parms
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 0.05 0.15 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # NatM_p_1_Fem_GP_1
 -10 45 22.1508 36 0 10 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 40 90 71.8079 70 0 10 4 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.05 0.25 0.147093 0.15 0 0.8 4 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.05 0.25 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.05 0.25 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
 -3 3 2.44e-006 2.44e-006 -1 0.8 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem
 -3 4 3.34694 3.34694 -1 0.8 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem
 50 60 55 55 -1 0.8 -3 0 0 0 0 0 0 0 # Mat50%_Fem
 -3 3 -0.25 -0.25 -1 0.8 -3 0 0 0 0 0 0 0 # Mat_slope_Fem
 -3 3 1 1 -1 0.8 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem
 -3 3 0 0 -1 0.8 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem
 0.05 0.15 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # NatM_p_1_Mal_GP_1
 1 45 0 36 -1 10 -3 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 40 90 69.6695 70 0 10 4 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0.05 0.25 0.161385 0.15 0 0.8 4 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.05 0.25 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0.05 0.25 0.1 0.1 -1 0.8 -3 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
 -3 3 2.44e-006 2.44e-006 -1 0.8 -3 0 0 0 0 0 0 0 # Wtlen_1_Mal
 -3 4 3.34694 3.34694 -1 0.8 -3 0 0 0 0 0 0 0 # Wtlen_2_Mal
 0 0 0 0 -1 0 -4 0 0 0 0 0 0 0 # RecrDist_GP_1
 0 0 0 0 -1 0 -4 0 0 0 0 0 0 0 # RecrDist_Area_1
 0 0 0 0 -1 0 -4 0 0 0 0 0 0 0 # RecrDist_Bseas_1
 0 0 0 0 -1 0 -4 0 0 0 0 0 0 0 # CohortGrowDev
 0.000001 0.999999 0.5 0.5 -1 0.5 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#
#_Cond 0  #custom_MG-env_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters
#
#_Cond 0  #custom_MG-block_setup (0/1)
#_LO HI INIT PRIOR PR_type SD PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters
#_Cond No MG parm trends
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_LO HI INIT PRIOR PR_type SD PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
#_Cond -4 #_MGparm_Dev_Phase
#
#_Spawner-Recruitment
3 #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepard_3Parm
#_LO HI INIT PRIOR PR_type SD PHASE
 3 31 8.95306 10.3 -1 10 1 # SR_LN(R0)
 0.2 1 0.647669 0.7 1 0.05 4 # SR_BH_steep
 0 2 0.6 0.8 -1 0.8 -4 # SR_sigmaR
 -5 5 0.1 0 -1 1 -3 # SR_envlink
 -5 5 0 0 -1 1 -4 # SR_R1_offset
 0 0 0 0 -1 0 -99 # SR_autocorr
0 #_SR_env_link
0 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1 #do_recdev:  0=none; 1=devvector; 2=simple deviations
1971 # first year of main recr_devs; early devs can preceed this era
2001 # last year of main recr_devs; forecast devs start in following year
2 #_recdev phase
1 # (0/1) to read 13 advanced options
 0 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 -4 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1900 #_last_early_yr_nobias_adj_in_MPD
 1900 #_first_yr_fullbias_adj_in_MPD
 2001 #_last_yr_fullbias_adj_in_MPD
 2002 #_first_recent_yr_nobias_adj_in_MPD
 1 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
# all recruitment deviations
#  1971R 1972R 1973R 1974R 1975R 1976R 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002F 2003F 2004F
#  0.333893 -0.172679 -0.154039 0.0571632 0.285534 0.442637 -0.400503 0.0615064 0.352022 -0.0797021 0.141684 -0.00260806 -0.522652 -0.322361 0.0768214 0.914228 0.0986032 0.130951 -0.18242 0.464425 -0.110084 -0.345367 -1.12631 0.378274 -0.268808 0.321053 0.916954 -0.249261 -1.08365 0.481312 -0.436625 0 0 0
# implementation error by year in forecast:  0 0 0
#
#Fishing Mortality info
0.3 # F ballpark
-2001 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
2.9 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
# if Fmethod=3; read N iterations for tuning for Fmethod 3
4  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms; count = 0
#_LO HI INIT PRIOR PR_type SD PHASE
#
# F rates by fleet
# Yr:  1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# FISHERY1 0 0.00188902 0.00954125 0.00963326 0.0192718 0.030225 0.0407963 0.0535069 0.066288 0.0934219 0.126709 0.139655 0.155072 0.17119 0.194029 0.215268 0.249512 0.264187 0.264515 0.249658 0.233424 0.156253 0.155305 0.153944 0.15536 0.160043 0.123695 0.1258 0.123694 0.124848 0.121992 0.0631818
#
#_Q_setup
 # Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm
#_for_env-var:_enter_index_of_the_env-var_to_be_linked
#_Den-dep  env-var  extra_se  Q_type Q_offset
 0 0 0 0 0 # 1 FISHERY1
 0 0 1 2 0 # 2 SURVEY1
 0 0 0 2 0 # 3 SURVEY2
#
#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index
#_Q_parms(if_any);Qunits_are_ln(q)
# LO HI INIT PRIOR PR_type SD PHASE
 0 0.5 0 0.05 1 0 -4 # Q_extraSD_SURVEY1(2)
 -7 5 0.583115 0 -1 1 1 # LnQ_base_SURVEY1(2)
 -7 5 -7 0 -1 1 1 # LnQ_base_SURVEY2(3)
#
#_size_selex_types
#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead
#_Pattern Discard Male Special
 1 2 0 0 # 1 FISHERY1
 1 0 0 0 # 2 SURVEY1
 0 0 0 0 # 3 SURVEY2
#
#_age_selex_types
#_Pattern ___ Male Special
 11 0 0 0 # 1 FISHERY1
 11 0 0 0 # 2 SURVEY1
 11 0 0 0 # 3 SURVEY2
#
1 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 19 80 53.4032 50 1 0.01 2 0 0 0 0 0 0 0 # SizeSel_P1_FISHERY1(1)
 0.01 60 18.8267 15 1 0.01 3 0 0 0 0 0 0 0 # SizeSel_P2_FISHERY1(1)
 20 70 38.6461 40 0 99 -3 0 0 0 0 0 0 0 # Retain_P1_FISHERY1(1)
 0.1 10 6.58451 1 0 99 -3 0 0 0 0 0 0 0 # Retain_P2_FISHERY1(1)
 0.001 1 0.98 1 0 99 -3 0 0 0 0 0 0 0 # Retain_P3_FISHERY1(1)
 -10 10 1 0 0 99 -3 0 0 0 0 0 0 0 # Retain_P4_FISHERY1(1)
  1 100 100   0   -1  99  -99  0   0   0   0   0   0   0 # Retain_P5_FISHERY1(1)
-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0 # Retain_P6_FISHERY1(1)
-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0 # Retain_P7_FISHERY1(1)
 0.1 1 46 0.8 0 99 -3 0 0 0 0 0 0 0 # DiscMort_P1_FISHERY1(1)
 -2 2 0.8 0 0 99 -3 0 0 0 0 0 0 0 # DiscMort_P2_FISHERY1(1)
 20 70 0.92 40 0 99 -3 0 0 0 0 0 0 0 # DiscMort_P3_FISHERY1(1)
 0.1 10 0 1 0 99 -3 0 0 0 0 0 0 0 # DiscMort_P4_FISHERY1(1)
-100 1 -100   0   -1  99  -99  0   0   0   0   0   0   0 # DiscMort_P5_FISHERY1(1)
-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0 # DiscMort_P6_FISHERY1(1)
-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0 # DiscMort_P7_FISHERY1(1)
 19 70 36.2751 30 1 0.01 2 0 0 0 0 0 0 0 # SizeSel_P1_SURVEY1(2)
 0.01 60 6.6277 10 1 0.01 3 0 0 0 0 0 0 0 # SizeSel_P2_SURVEY1(2)
 0 40 0 5 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P1_FISHERY1(1)
 0 40 40 6 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P2_FISHERY1(1)
 0 40 0 5 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P1_SURVEY1(2)
 0 40 40 6 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P2_SURVEY1(2)
 0 40 0 5 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P1_SURVEY2(3)
 0 40 0 6 -1 99 -1 0 0 0 0 0 0 0 # AgeSel_P2_SURVEY2(3)
#_Cond 0 #_custom_sel-env_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no enviro fxns
#_Cond 0 #_custom_sel-blk_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no block usage
#_Cond No selex parm trends
#_Cond -4 # placeholder for selparm_Dev_Phase
#_Cond 0 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
# Input variance adjustments; factors:
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized sizecomp (not implemented yet)
#_Factor  Fleet  Value
 -9999 1 0  # terminator
#
4 #_maxlambdaphase
1 #_sd_offset
# read 3 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch;
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark
#like_comp fleet  phase  value  sizefreq_method
 1 2 2 1 1
 4 2 2 1 1
 4 2 3 1 1
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 0 0 0 #_CPUE/survey:_1
#  1 1 1 1 #_CPUE/survey:_2
#  1 1 1 1 #_CPUE/survey:_3
#  1 1 1 1 #_discard:_1
#  0 0 0 0 #_discard:_2
#  0 0 0 0 #_discard:_3
#  1 1 1 1 #_meanbodywt:1
#  1 1 1 1 #_meanbodywt:2
#  1 1 1 1 #_meanbodywt:3
#  1 1 1 1 #_lencomp:_1
#  1 1 1 1 #_lencomp:_2
#  0 0 0 0 #_lencomp:_3
#  1 1 1 1 #_agecomp:_1
#  1 1 1 1 #_agecomp:_2
#  0 0 0 0 #_agecomp:_3
#  1 1 1 1 #_size-age:_1
#  1 1 1 1 #_size-age:_2
#  0 0 0 0 #_size-age:_3
#  1 1 1 1 #_init_equ_catch
#  1 1 1 1 #_recruitments
#  1 1 1 1 #_parameter-priors
#  1 1 1 1 #_parameter-dev-vectors
#  1 1 1 1 #_crashPenLambda
#  0 0 0 0 # F_ballpark_lambda
1 # (0/1) read specs for more stddev reporting
 1 1 -1 5 1 5 1 -1 5 # selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages
 5 15 25 35 43 # vector with selex std bin picks (-1 in first bin to self-generate)
 1 2 14 26 40 # vector with growth std bin picks (-1 in first bin to self-generate)
 1 2 14 26 40 # vector with NatAge std bin picks (-1 in first bin to self-generate)
999

