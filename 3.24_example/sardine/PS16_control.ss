#V3.24S
#_data_and_control_files: T_2016.dat // T_2016.ctl
#_SS-V3.24S-safe;_07/24/2013;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_10.1
1  #_N_Growth_Patterns
1 #_N_Morphs_Within_GrowthPattern 
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond  1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#
1 #  number of recruitment assignments (overrides GP*area*seas parameter values) 
0 # recruitment interaction requested
#GP seas area for each recruitment assignment
 1 1 1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 1 #_blocks_per_pattern 
# begin and end years of blocks
 1999 2015
#
0.5 #_fracfemale 
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
  #_no additional input for selected M option; read 1P per morph
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
0.5 #_Growth_Age_for_L1
999 #_Growth_Age_for_L2 (999 to use as Linf)
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity by GP; 4=read age-fecundity by GP; 5=read fec and wt from wtatage.ss; 6=read length-maturity by GP
#_placeholder for empirical age- or length- maturity by growth pattern (female only)
0 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
1 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#_growth_parms
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 0.3 0.7 0.4 0 -1 99 -3 0 0 0 0 0 0 0 # NatM_p_1_Fem_GP_1
 3 15 11.2948 0 -1 99 3 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 20 30 23.3583 0 -1 99 3 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.05 0.99 0.432271 0 -1 99 3 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.05 0.3 0.137464 0 -1 99 3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.1 0.0477508 0 -1 99 3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
 -3 3 7.5242e-006 0 -1 99 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem
 -3 5 3.2332 0 -1 99 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem
 9 19 15.44 0 -1 99 -3 0 0 0 0 0 0 0 # Mat50%_Fem
 -20 3 -0.89252 0 -1 99 -3 0 0 0 0 0 0 0 # Mat_slope_Fem
 0 10 1 0 -1 99 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem
 -1 5 0 0 -1 99 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem
 -4 4 0 0 -1 99 -3 0 0 0 0 0 0 0 # RecrDist_GP_1
 -4 4 1 0 -1 99 -3 0 0 0 0 0 0 0 # RecrDist_Area_1
 -4 4 1 0 -1 99 -3 0 0 0 0 0 0 0 # RecrDist_Seas_1
 -4 4 0 0 -1 99 -3 0 0 0 0 0 0 0 # RecrDist_Seas_2
 1 1 1 0 -1 99 -3 0 0 0 0 0 0 0 # CohortGrowDev
#
#_Cond 0  #custom_MG-env_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters
#
#_Cond 0  #custom_MG-block_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters
#_Cond No MG parm trends 
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
#_Cond -4 #_MGparm_Dev_Phase
#
#_Spawner-Recruitment
3 #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm
#_LO HI INIT PRIOR PR_type SD PHASE
 3 25 14.7509 0 -1 99 1 # SR_LN(R0)
 0.2 1 0.8 0 -1 99 -6 # SR_BH_steep
 0 2 0.75 0 -1 99 -3 # SR_sigmaR
 -5 5 0 0 -1 99 -3 # SR_envlink
 -15 15 -0.209686 0 -1 99 2 # SR_R1_offset
 0 0 0 0 -1 99 -3 # SR_autocorr
0 #_SR_env_link
0 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1 #do_recdev:  0=none; 1=devvector; 2=simple deviations
1993 # first year of main recr_devs; early devs can preceed this era
2014 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -6 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 2 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1984 #_last_early_yr_nobias_adj_in_MPD
 1993 #_first_yr_fullbias_adj_in_MPD
 2011 #_last_yr_fullbias_adj_in_MPD
 2015 #_first_recent_yr_nobias_adj_in_MPD
 0.93 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
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
#DisplayOnly -0.343848 # Early_InitAge_6
#DisplayOnly -0.379244 # Early_InitAge_5
#DisplayOnly -0.372521 # Early_InitAge_4
#DisplayOnly -0.0740259 # Early_InitAge_3
#DisplayOnly 0.375998 # Early_InitAge_2
#DisplayOnly 1.43213 # Early_InitAge_1
#DisplayOnly 1.18021 # Main_RecrDev_1993
#DisplayOnly 0.0656293 # Main_RecrDev_1994
#DisplayOnly 0.529691 # Main_RecrDev_1995
#DisplayOnly 1.6913 # Main_RecrDev_1996
#DisplayOnly 1.34523 # Main_RecrDev_1997
#DisplayOnly -0.458488 # Main_RecrDev_1998
#DisplayOnly -0.369406 # Main_RecrDev_1999
#DisplayOnly 0.36715 # Main_RecrDev_2000
#DisplayOnly -1.70873 # Main_RecrDev_2001
#DisplayOnly 1.98922 # Main_RecrDev_2002
#DisplayOnly 1.29001 # Main_RecrDev_2003
#DisplayOnly 1.80654 # Main_RecrDev_2004
#DisplayOnly 0.605701 # Main_RecrDev_2005
#DisplayOnly 1.04173 # Main_RecrDev_2006
#DisplayOnly -0.030958 # Main_RecrDev_2007
#DisplayOnly 1.01727 # Main_RecrDev_2008
#DisplayOnly -0.247317 # Main_RecrDev_2009
#DisplayOnly -2.16422 # Main_RecrDev_2010
#DisplayOnly -3.34735 # Main_RecrDev_2011
#DisplayOnly -2.95992 # Main_RecrDev_2012
#DisplayOnly -1.63673 # Main_RecrDev_2013
#DisplayOnly -0.0065655 # Main_RecrDev_2014
#DisplayOnly 0 # Late_RecrDev_2015
#DisplayOnly 0 # ForeRecr_2016
#DisplayOnly 0 # Impl_err_2016
#
#Fishing Mortality info 
0.1 # F ballpark for annual F (=Z-M) for specified year
-2006 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
# if Fmethod=3; read N iterations for tuning for Fmethod 3
10  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms
#_LO HI INIT PRIOR PR_type SD PHASE
 0 4 0 0 -1 99 -1 # InitF_1MexCal_S1_NSP
 0 4 0 0 -1 99 -1 # InitF_2MexCal_S2_NSP
 0 4 0 0 -1 99 -1 # InitF_3PacNW
#
#_Q_setup
 # Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm
#_for_env-var:_enter_index_of_the_env-var_to_be_linked
#_Den-dep  env-var  extra_se  Q_type
 0 0 0 0 # 1 MexCal_S1_NSP
 0 0 0 0 # 2 MexCal_S2_NSP
 0 0 0 0 # 3 PacNW
 0 0 0 2 # 4 DEPM
 0 0 0 2 # 5 TEP
 0 0 0 2 # 6 TEP_full
 0 0 0 2 # 7 Aerial
 0 0 0 2 # 8 ATM_Spring
 0 0 0 -8 # 9 ATM_Summer
#
#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index
#_Q_parms(if_any);Qunits_are_ln(q)
# LO HI INIT PRIOR PR_type SD PHASE
 -3 3 -1.4099 0 -1 99 5 # LnQ_base_4_DEPM
 -3 3 -0.274202 0 -1 99 5 # LnQ_base_5_TEP
 -3 3 -0.432001 0 -1 99 5 # LnQ_base_6_TEP_full
 -3 3 0.0294018 0 -1 99 5 # LnQ_base_7_Aerial
 -3 3 0 0 -1 99 -5 # LnQ_base_8_ATM_Spring
#
#_size_selex_types
#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead
#_Pattern Discard Male Special
 24 0 0 0 # 1 MexCal_S1_NSP
 24 0 0 0 # 2 MexCal_S2_NSP
 24 0 0 0 # 3 PacNW
 30 0 0 0 # 4 DEPM
 30 0 0 0 # 5 TEP
 30 0 0 0 # 6 TEP_full
 24 0 0 0 # 7 Aerial
 24 0 0 0 # 8 ATM_Spring
 24 0 0 0 # 9 ATM_Summer
#
#_age_selex_types
#_Pattern ___ Male Special
 0 0 0 0 # 1 MexCal_S1_NSP
 0 0 0 0 # 2 MexCal_S2_NSP
 0 0 0 0 # 3 PacNW
 0 0 0 0 # 4 DEPM
 0 0 0 0 # 5 TEP
 0 0 0 0 # 6 TEP_full
 0 0 0 0 # 7 Aerial
 0 0 0 0 # 8 ATM_Spring
 0 0 0 0 # 9 ATM_Summer
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 10 28 18.5252 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_1P_1_MexCal_S1_NSP
 -5 3 -4.985 0 -1 99 -4 0 0 0 0 0 1 2 # SizeSel_1P_2_MexCal_S1_NSP
 -1 9 2.86221 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_1P_3_MexCal_S1_NSP
 -1 9 0.53616 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_1P_4_MexCal_S1_NSP
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 1 2 # SizeSel_1P_5_MexCal_S1_NSP
 -10 10 -3.51168 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_1P_6_MexCal_S1_NSP
 10 28 16.3516 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_2P_1_MexCal_S2_NSP
 -5 3 -4.993 0 -1 99 -4 0 0 0 0 0 1 2 # SizeSel_2P_2_MexCal_S2_NSP
 -1 9 1.78232 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_2P_3_MexCal_S2_NSP
 -1 9 1.84849 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_2P_4_MexCal_S2_NSP
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 1 2 # SizeSel_2P_5_MexCal_S2_NSP
 -10 10 -2.33663 0 -1 99 4 0 0 0 0 0 1 2 # SizeSel_2P_6_MexCal_S2_NSP
 10 28 20.8528 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_3P_1_PacNW
 -5 10 2.5 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_3P_2_PacNW
 -5 10 1.8124 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_3P_3_PacNW
 -5 10 5 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_3P_4_PacNW
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_3P_5_PacNW
 -10 10 10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_3P_6_PacNW
 10 28 19 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_7P_1_Aerial
 -5 3 3 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_7P_2_Aerial
 -1 9 4 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_7P_3_Aerial
 -1 9 4 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_7P_4_Aerial
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_7P_5_Aerial
 -10 10 10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_7P_6_Aerial
 10 28 16.6602 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_8P_1_ATM_Spring
 -5 3 3 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_8P_2_ATM_Spring
 -1 9 -0.846111 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_8P_3_ATM_Spring
 -1 9 4 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_8P_4_ATM_Spring
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_8P_5_ATM_Spring
 -10 10 10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_8P_6_ATM_Spring
 10 28 22.2953 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_9P_1_ATM_Summer
 -5 3 3 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_9P_2_ATM_Summer
 -1 9 2.12187 0 -1 99 4 0 0 0 0 0 0 0 # SizeSel_9P_3_ATM_Summer
 -1 9 4 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_9P_4_ATM_Summer
 -10 10 -10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_9P_5_ATM_Summer
 -10 10 10 0 -1 99 -4 0 0 0 0 0 0 0 # SizeSel_9P_6_ATM_Summer
#_Cond 0 #_custom_sel-env_setup (0/1) 
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no enviro fxns
1 #_custom_sel-blk_setup (0/1) 
 10 28 17.0972 0 -1 99 4 # SizeSel_1P_1_MexCal_S1_NSP_BLK1repl_1999
 -5 3 -4.998 0 -1 99 -4 # SizeSel_1P_2_MexCal_S1_NSP_BLK1repl_1999
 -1 9 2.11624 0 -1 99 4 # SizeSel_1P_3_MexCal_S1_NSP_BLK1repl_1999
 -1 9 -0.305173 0 -1 99 4 # SizeSel_1P_4_MexCal_S1_NSP_BLK1repl_1999
 -10 10 -10 0 -1 99 -4 # SizeSel_1P_5_MexCal_S1_NSP_BLK1repl_1999
 -10 10 -2.21753 0 -1 99 4 # SizeSel_1P_6_MexCal_S1_NSP_BLK1repl_1999
 10 28 14.7441 0 -1 99 4 # SizeSel_2P_1_MexCal_S2_NSP_BLK1repl_1999
 -5 3 -4.997 0 -1 99 -4 # SizeSel_2P_2_MexCal_S2_NSP_BLK1repl_1999
 -1 9 1.53425 0 -1 99 4 # SizeSel_2P_3_MexCal_S2_NSP_BLK1repl_1999
 -1 9 1.91684 0 -1 99 4 # SizeSel_2P_4_MexCal_S2_NSP_BLK1repl_1999
 -10 10 -10 0 -1 99 -4 # SizeSel_2P_5_MexCal_S2_NSP_BLK1repl_1999
 -10 10 -2.54225 0 -1 99 4 # SizeSel_2P_6_MexCal_S2_NSP_BLK1repl_1999
#_Cond No selex parm trends 
#_Cond -4 # placeholder for selparm_Dev_Phase
1 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
1 #_Variance_adjustments_to_input_values
#_fleet: 1 2 3 4 5 6 7 8 9 
  0 0 0 0 0 0 0 0 0 #_add_to_survey_CV
  0 0 0 0 0 0 0 0 0 #_add_to_discard_stddev
  0 0 0 0 0 0 0 0 0 #_add_to_bodywt_CV
  1 1 1 1 1 1 1 1 1 #_mult_by_lencomp_N
  1 1 1 1 1 1 1 1 1 #_mult_by_agecomp_N
  1 1 1 1 1 1 1 1 1 #_mult_by_size-at-age_N
#
1 #_maxlambdaphase
1 #_sd_offset
#
25 # number of changes to make to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark
#like_comp fleet/survey  phase  value  sizefreq_method
 1 4 1 1 1
 1 5 1 1 1
 1 6 1 0 1
 1 7 1 0 1
 1 8 1 1 1
 1 9 1 1 1
 4 1 1 1 1
 4 2 1 1 1
 4 3 1 1 1
 4 7 1 0 1
 4 8 1 1 1
 4 9 1 1 1
 5 1 1 0.2 1
 5 2 1 0.2 1
 5 3 1 0.2 1
 5 8 1 0 1
 5 9 1 0 1
 7 1 1 0 1
 7 2 1 0 1
 7 3 1 0 1
 7 8 1 0 1
 7 9 1 0 1
 9 1 1 0 1
 9 2 1 0 1
 9 3 1 0 1
#
# lambdas (for info only; columns are phases)
#  0 #_CPUE/survey:_1
#  0 #_CPUE/survey:_2
#  0 #_CPUE/survey:_3
#  1 #_CPUE/survey:_4
#  1 #_CPUE/survey:_5
#  0 #_CPUE/survey:_6
#  0 #_CPUE/survey:_7
#  1 #_CPUE/survey:_8
#  1 #_CPUE/survey:_9
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  1 #_lencomp:_3
#  0 #_lencomp:_4
#  0 #_lencomp:_5
#  0 #_lencomp:_6
#  0 #_lencomp:_7
#  1 #_lencomp:_8
#  1 #_lencomp:_9
#  0.2 #_agecomp:_1
#  0.2 #_agecomp:_2
#  0.2 #_agecomp:_3
#  0 #_agecomp:_4
#  0 #_agecomp:_5
#  0 #_agecomp:_6
#  0 #_agecomp:_7
#  0 #_agecomp:_8
#  0 #_agecomp:_9
#  0 #_size-age:_1
#  0 #_size-age:_2
#  0 #_size-age:_3
#  0 #_size-age:_4
#  0 #_size-age:_5
#  0 #_size-age:_6
#  0 #_size-age:_7
#  0 #_size-age:_8
#  0 #_size-age:_9
#  0 #_init_equ_catch
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  0 # F_ballpark_lambda
0 # (0/1) read specs for more stddev reporting 
 # 0 1 -1 5 1 5 1 -1 5 # placeholder for selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages
 # placeholder for vector of selex bins to be reported
 # placeholder for vector of growth ages to be reported
 # placeholder for vector of NatAges ages to be reported
999

