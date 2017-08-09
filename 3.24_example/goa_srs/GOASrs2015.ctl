#V3.24S
#_data_and_control_files: GOASrs2013.dat // GOASrs2013.ctl
#_SS-V3.24S-safe-win64;_07/24/2013;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.1
1  #_N_Growth_Patterns
1 #_N_Morphs_Within_GrowthPattern
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond  1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#
#_Cond 0  #  N recruitment designs goes here if N_GP*nseas*area>1
#_Cond 0  #  placeholder for recruitment interaction request
#_Cond 1 1 1  # example recruitment design element for GP=1, seas=1, area=1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
0 #_Nblock_Patterns
#_Cond 0 #_blocks_per_pattern
# begin and end years of blocks
#
0.5 #_fracfemale
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
  #_no additional input for selected M option; read 1P per morph
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
3.0833333 #_Growth_Age_for_L1
999 #_Growth_Age_for_L2 (999 to use as Linf)
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
2 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
3 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity by GP; 4=read age-fecundity by GP; 5=read fec and wt from wtatage.ss; 6=read length-maturity by GP
#_Age_Maturity by growth pattern for females
 0 0 0 0 0 0.01 0.04 0.15 0.37 0.63 0.82 0.91 0.96 0.98 0.99 0.99 0.99 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
1 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
1 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#_growth_parms
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 0 1 0.2 0 -1 0 -3 0 0 0 0 0 0 0 # NatM_p_1_Fem_GP_1
 5 35 12.0 0 -1 0 3 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 20 70 49.0 0 -1 0 3 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.17 0 -1 0 3 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 2.5 0 -1 0 3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0 20 4.5 0 -1 0 3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
 0 1 0.20 0 -1 0 3 0 0 0 0 0 0 0 # NatM_p_1_Mal_GP_1
 5 35 12.0 0 -1 0 3 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 20 70 40.0 0 -1 0 3 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0 1 0.19 0 -1 0 3 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0 10 2.3 0 -1 0 3 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0 20 4.3 0 -1 0 3 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
 -99 99 9.984e-006 0 -1 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Fem
 -99 99 3.0468 0 -1 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Fem
 -99 99 33.75 0 -1 0 -1 0 0 0 0 0 0 0 # Mat50%_Fem
 -99 99 -1.9632 0 -1 0 -1 0 0 0 0 0 0 0 # Mat_slope_Fem
 -99 99 1 0 -1 0 -1 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem
 -99 99 0 0 -1 0 -1 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem
 -99 99 9.984e-006 0 -1 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Mal
 -99 99 3.0468 0 -1 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Mal
 -99 99 1 0 -1 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_1
 -99 99 1 0 -1 0 -1 0 0 0 0 0 0 0 # RecrDist_Area_1
 -99 99 1 0 -1 0 -1 0 0 0 0 0 0 0 # RecrDist_Seas_1
 -99 99 1 0 -1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
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
 10 30 11.9 0 -1 0 1 # SR_LN(R0)
 -99 99 1 0 -1 0 -1 # SR_BH_steep
 0 10 0.6 0 -1 0 -1 # SR_sigmaR
 -99 99 0 0 -1 0 -1 # SR_envlink
 -5 5 0.0 0 -1 0 3 # SR_R1_offset
 -99 99 0 0 -1 0 -1 # SR_autocorr
1 #_SR_env_link
2 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1 #do_recdev:  0=none; 1=devvector; 2=simple deviations
1977 # first year of main recr_devs; early devs can preceed this era
2012 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 4 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1976 #_last_early_yr_nobias_adj_in_MPD
 1986 #_first_yr_fullbias_adj_in_MPD
 2012 #_last_yr_fullbias_adj_in_MPD
 2016 #_first_recent_yr_nobias_adj_in_MPD
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
#
#Fishing Mortality info
0.2 # F ballpark for annual F (=Z-M) for specified year
1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
3 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
# if Fmethod=3; read N iterations for tuning for Fmethod 3
5  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms
#_LO HI INIT PRIOR PR_type SD PHASE
 0 1 0.1 0 -1 0 1 # InitF_1FshTrawl
#
#_Q_setup
 # Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm
#_for_env-var:_enter_index_of_the_env-var_to_be_linked
#_Den-dep  env-var  extra_se  Q_type
 0 0 0 0 # 1 FshTrawl
 0 0 0 2 # 2 Srv
#
#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index
#_Q_parms(if_any);Qunits_are_ln(q)
# LO HI INIT PRIOR PR_type SD PHASE
# -5 5 0 0 -1 0 -5 # Q_envlink_2_Srv
 -5 5 0 0 -1 0 -5 # LnQ_base_2_Srv
#
#_size_selex_types
#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead
#_Pattern Discard Male Special
 24 0 3 0 # 1 FshTrawl
 24 0 3 0 # 2 Srv
#
#_age_selex_types
#_Pattern ___ Male Special
 10 0 0 0 # 1 FshTrawl
 10 0 0 0 # 2 Srv

#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
  10 65 35 0 -1 0 4 0 0 0 0 0 0 0 # SizeSel_1P_1_FshTrawl
 -10 10  1 0 -1 0 4 0 0 0 0 0 0 0 # SizeSel_1P_2_FshTrawl
 -10 10  5 0 -1 0 4 0 0 0 0 0 0 0 # SizeSel_1P_3_FshTrawl
 -10 10  4 0 -1 0 4 0 0 0 0 0 0 0 # SizeSel_1P_4_FshTrawl
 -10 10 -10 0 -1 0 -4 0 0 0 0 0 0 0 # SizeSel_1P_5_FshTrawl
 -10 10  0 0 -1 0 4 0 0 0 0 0 0 0 # SizeSel_1P_6_FshTrawl

 -30 30  0 0 -1 0 4 0 0 0 0 0 0 0 # SzSel_1Male_Peak_FshTrawl
 -10 10  0 0 -1 0 4 0 0 0 0 0 0 0 # SzSel_1Male_Ascend_FshTrawl
 -15 15  0 0 -1 0 -4 0 0 0 0 0 0 0 # SzSel_1Male_Descend_FshTrawl
 -10 10  0 0 -1 0 -4 0 0 0 0 0 0 0 # SzSel_1Male_Final_FshTrawl
 0.3  1  1 0 -1 0 -4 0 0 0 0 0 0 0 # SzSel_1Male_Scale_FshTrawl

  10 65 25 0 -1 0 5 0 0 0 0 0 0 0 # AgeSel_2P_1_Srv
 -10 10  0 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2P_2_Srv
 -10 10  5 0 -1 0 5 0 0 0 0 0 0 0 # AgeSel_2P_3_Srv
 -10 10  0 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2P_4_Srv
 -10 10 -10 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2P_5_Srv
 -10 10  10 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2P_6_Srv

 -30 30  0 0 -1 0 5 0 0 0 0 0 0 0 # AgeSel_2Male_Peak_Srv
 -10 10  0 0 -1 0 5 0 0 0 0 0 0 0 # AgeSel_2Male_Ascend_Srv
 -15 15  0 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2Male_Descend_Srv
 -10 10  0 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2Male_Final_Srv
 0.3  1  1 0 -1 0 -5 0 0 0 0 0 0 0 # AgeSel_2Male_Scale_Srv

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
#
1 #_Variance_adjustments_to_input_values
#_fleet: 1 2
  0 0 #_add_to_survey_CV
  0 0 #_add_to_discard_stddev
  0 0 #_add_to_bodywt_CV
  1 1 #_mult_by_lencomp_N
  0 1 #_mult_by_agecomp_N
  0 1 #_mult_by_size-at-age_N
#
1 #_maxlambdaphase
1 #_sd_offset
#
0 # number of changes to make to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch;
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark
#like_comp fleet/survey  phase  value  sizefreq_method
# 1 2 1 5 1
#
# lambdas (for info only; columns are phases)
#  0 #_CPUE/survey:_1
#  5 #_CPUE/survey:_2
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  0 #_agecomp:_1
#  1 #_agecomp:_2
#  1 #_init_equ_catch
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  1 # F_ballpark_lambda
0 # (0/1) read specs for more stddev reporting
 # 0 1 -1 5 1 5 1 -1 5 # placeholder for selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages
 # placeholder for vector of selex bins to be reported
 # placeholder for vector of growth ages to be reported
 # placeholder for vector of NatAges ages to be reported
999

