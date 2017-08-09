#C 2017 Hake forecast file - pre-SRG
###################################################

1       # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy
2       # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr)
0.4     # SPR target (e.g. 0.40)
0.4     # Biomass target (e.g. 0.40)
# Enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
-999 -999 -999 -999 -999 -999 # Bmark_years: beg_bio end_bio beg_selex end_selex beg_alloc end_alloc
2       # Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
1       # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (use first-last alloc yrs); 5=input annual F
3       # N forecast years
1.0     # F scalar (only used for Do_Forecast==5)
# Enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
-4 0 -4 0 # Fcast_years:  beg_selex end_selex beg_alloc end_alloc
1       # Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) )
0.4     # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40)
0.1     # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10)
1.0     # Control rule target as fraction of Flimit (e.g. 0.75)
3       # N forecast loops (1-3) (fixed at 3 for now)
3       # First forecast loop with stochastic recruitment
-1      # Forecast loop control #3 (reserved)
0       #_Forecast loop control #4 (reserved for future bells&whistles)
0       #_Forecast loop control #5 (reserved for future bells&whistles)
2019    # FirstYear for caps and allocations (should be after any fixed inputs)
0.0     # stddev of log(realized catch/target catch) in forecast
0       # Do West Coast gfish rebuilder output (0/1)
1999    # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
2002    # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
1       # fleet relative F:  1=use first-last alloc year; 2=read seas(row) x fleet(col) below
2       # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)
-1      # max totalcatch by fleet (-1 to have no max)
-1      # max totalcatch by area (-1 to have no max)
0       # fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)
# assign fleets to groups
# allocation fraction for each of: 2 allocation groups
0 # Number of forecast catch levels to input (else calc catch from forecast F)
2 # basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F) (units are from fleetunits; note new codes in SSV3.20)

999 # verify end of input
