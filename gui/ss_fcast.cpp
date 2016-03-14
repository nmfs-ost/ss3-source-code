#include "ss_forecast.h"

ss_forecast::ss_forecast(QObject *parent) :
    QObject(parent)
{
    // set defaults
    reset ();
}

ss_forecast::~ss_forecast()
{
    clear();
}

void ss_forecast::set_max_catch_fleet(int flt, int ctch)
{
    for (int i = i_max_catch_fleet.count(); i <= flt; i++)
        i_max_catch_fleet.append(0.0);
    i_max_catch_fleet[flt] = ctch;
}

void ss_forecast::set_max_catch_area(int flt, int ctch)
{
    for (int i = i_max_catch_area.count(); i <= flt; i++)
        i_max_catch_area.append(0);
    i_max_catch_area[flt] = ctch;
}

void ss_forecast::set_alloc_group(int flt, int grp)
{
    int i;
    for (i = i_alloc_grp_list.count(); i <= flt; i++)
        i_alloc_grp_list.append(0);
    i_alloc_grp_list[flt] = grp;

    for (i = f_alloc_grp_frac.count(); i <= grp; i++)
        f_alloc_grp_frac.append(0.0);
    i_num_alloc_groups = i;
}

void ss_forecast::add_fixed_catch_value(observation *obs)
{
    if (obs != NULL)
        o_fixed_ctch_list.append(obs);
}

void ss_forecast::reset()
{
    i_bmark = 0; // Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy
    i_msy = 1;   // MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr)
    f_spr_tgt = 0.40;  // SPR target (e.g. 0.40)
    f_bmass_tgt = 0.40;// Biomass target (e.g. 0.40)
    for (int i = 0; i < 6; i++)
        i_bmark_yrs[i] = 0;// Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF (enter actual year, or values of 0 or -integer to be rel. endyr)
    i_bmark_rel_f = 1; // Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
    i_method = 0;      // Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
    i_num_fcast_yrs = 0;// N forecast years
    f_f_scalar = 0.0;  // F scalar (only used for Do_Forecast==5)
    for (int i = 0; i < 4; i++)
        i_fcast_yrs[i] = 0;// Fcast_years:  beg_selex, end_selex, beg_relF, end_relF  (enter actual year, or values of 0 or -integer to be rel. endyr)
    i_ctl_rule_method = 1;// Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) )
    f_ctl_rule_bmass_const_f = 0.40;// Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below)
    f_ctl_rule_bmass_no_f = 0.10;// Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10)
    f_ctl_rule_tgt = 0.75;// Control rule target as fraction of Flimit (e.g. 0.75)
    i_num_fcast_loops = 1;// N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
    i_fcast_loop_stch_recruit = 1;// First forecast loop with stochastic recruitment
    i_fcast_loop_3 = 0;// Forecast loop control #3 (reserved for future bells&whistles)
    i_fcast_loop_4 = 0;// Forecast loop control #4 (reserved for future bells&whistles)
    i_fcast_loop_5 = 0;// Forecast loop control #5 (reserved for future bells&whistles)
    i_caps_st_year = 0;// FirstYear for caps and allocations (should be after years with fixed inputs)
    f_log_ctch_stdv = 0.0;// stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)
    b_rebuilder = 0;// Do West Coast gfish rebuilder output (0/1)
    i_rebuilder_st_yr = 0;// Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
    i_rebuilder_cur_yr = 0;// Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
    i_fleet_rel_f = 1;// fleet relative F:  1=use first-last alloc year; 2=read seas(row) x fleet(col) below
    //# Note that fleet allocation is used directly as average F if Do_Forecast=4
    i_ctch_basis = 2;// basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)
    //# Conditional input if relative F choice = 2
    //# Fleet relative F:  rows are seasons, columns are fleets
    //#_Fleet:  FISHERY1
    //#  1
    i_seas_fleet_rel_f_list.clear();//
    //# max totalcatch by fleet (-1 to have no max) must enter value for each fleet
    i_max_catch_fleet.clear();//
    //# max totalcatch by area (-1 to have no max); must enter value for each fleet
    i_max_catch_area.clear();//
    //# fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)
    i_alloc_grp_list.clear();//
    i_num_alloc_groups = 0;//
    //#_Conditional on >1 allocation group
    //# allocation fraction for each of: 0 allocation groups
    f_alloc_grp_frac.clear();//
    //# no allocation groups
    i_num_fcast_ctch_levels = 0;// Number of forecast catch levels to input (else calc catch from forecast F)
    i_input_fcast_ctch_basis = 2;// basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F) (units are from fleetunits; note new codes in SSV3.20)
    //# Input fixed catch values
    //#Year Seas Fleet Catch(or_F)
    o_fixed_ctch_list.clear();
}

void ss_forecast::clear()
{
    i_bmark = 0;
    i_msy = 0;
    f_spr_tgt = 0.0;
    f_bmass_tgt = 0.0;
    for (int i = 0; i < 6; i++)
        i_bmark_yrs[i] = 0;
    i_bmark_rel_f = 0;
    i_method = 0;
    i_num_fcast_yrs = 0;
    f_f_scalar = 0.0;
    for (int i = 0; i < 4; i++)
        i_fcast_yrs[i] = 0;
    i_ctl_rule_method = 1;
    f_ctl_rule_bmass_const_f = 0.0;
    f_ctl_rule_bmass_no_f = 0.0;
    f_ctl_rule_tgt = 0.0;
    i_num_fcast_loops = 1;
    i_fcast_loop_stch_recruit = 1;
    i_fcast_loop_3 = 0;
    i_fcast_loop_4 = 0;
    i_fcast_loop_5 = 0;
    i_caps_st_year = 0;
    f_log_ctch_stdv = 0.0;
    b_rebuilder = 0;
    i_rebuilder_st_yr = 0;
    i_rebuilder_cur_yr = 0;
    i_fleet_rel_f = 0;
    i_ctch_basis = 0;
    i_seas_fleet_rel_f_list.clear();
    i_max_catch_fleet.clear();
    i_max_catch_area.clear();
    i_alloc_grp_list.clear();
    i_num_alloc_groups = 0;
    f_alloc_grp_frac.clear();
    i_num_fcast_ctch_levels = 0;
    i_input_fcast_ctch_basis = 0;
    while (o_fixed_ctch_list.count())
    {
        observation *obs = o_fixed_ctch_list.takeFirst();
        delete obs;
    }
    o_fixed_ctch_list.clear();
}

