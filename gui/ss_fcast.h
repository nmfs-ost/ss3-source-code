#ifndef SS_FORECAST_H
#define SS_FORECAST_H

#include <QObject>
#include <QList>

#include "observation.h"

class ss_forecast : public QObject
{
    Q_OBJECT

public:
    explicit ss_forecast(QObject *parent = 0);
    ~ss_forecast();

public slots:
    void set_benchmarks (int bmark) {i_bmark = bmark;}
    int benchmarks () {return i_bmark;}
    void set_MSY (int msy) {i_msy = msy;}
    int MSY () {return i_msy;}
    void set_spr_target (float spr) {f_spr_tgt = spr;}
    float spr_target () {return f_spr_tgt;}
    void set_biomass_target (float bmss) {f_bmass_tgt = bmss;}
    float biomass_target () {return f_bmass_tgt;}
    void set_benchmark_years (int i, int yr) {i_bmark_yrs[i] = yr;}
    int benchmark_year (int i) {return i_bmark_yrs[i];}
    void set_benchmark_rel_f (int relf) {i_bmark_rel_f = relf;}
    int benchmark_rel_f () {return i_bmark_rel_f;}
    void set_forecast (int fcast) {i_method = fcast;}
    int forecast () {return i_method;}
    void set_num_forecast_years (int yrs) {i_num_fcast_yrs = yrs;}
    int num_forecast_years () {return i_num_fcast_yrs;}
    void set_forecast_year (int i, int yr) {i_fcast_yrs[i] = yr;}
    int forecast_year (int i) {return i_fcast_yrs[i];}
    void set_cr_method (int ctl) {i_ctl_rule_method = ctl;}
    int cr_method () {return i_ctl_rule_method;}
    void set_f_scalar (float f) {f_f_scalar = f;}
    float f_scalar () {return f_f_scalar;}
    void set_cr_biomass_const_f (float cr) {f_ctl_rule_bmass_const_f = cr;}
    float cr_biomass_const_f () {return f_ctl_rule_bmass_const_f;}
    void set_cr_biomass_no_f (float cr) {f_ctl_rule_bmass_no_f = cr;}
    float cr_biomass_no_f () {return f_ctl_rule_bmass_no_f;}
    void set_cr_target (float targ) {f_ctl_rule_tgt = targ;}
    float cr_target () {return f_ctl_rule_tgt;}
    void set_num_forecast_loops (int loops) {i_num_fcast_loops = loops;}
    int num_forecast_loops () {return i_num_fcast_loops;}
    void set_forecast_loop_recruitment (int loop) {i_fcast_loop_stch_recruit = loop;}
    int forecast_loop_recruitment () {return i_fcast_loop_stch_recruit;}
    void set_forecast_loop_ctl3 (int floop) {i_fcast_loop_3 = floop;}
    int forecast_loop_ctl3 () {return i_fcast_loop_3;}
    void set_forecast_loop_ctl4 (int floop) {i_fcast_loop_4 = floop;}
    int forecast_loop_ctl4 () {return i_fcast_loop_4;}
    void set_forecast_loop_ctl5 (int floop) {i_fcast_loop_5 = floop;}
    int forecast_loop_ctl5 () {return i_fcast_loop_5;}
    void set_caps_alloc_st_year (int yr) {i_caps_st_year = yr;}
    int caps_alloc_st_year () {return i_caps_st_year;}
    void set_log_catch_std_dev (float sd) {f_log_ctch_stdv = sd;}
    float log_catch_std_dev () {return f_log_ctch_stdv;}
    void set_rebuilder (bool flag) {b_rebuilder = flag;}
    bool rebuilder () {return b_rebuilder;}
    void set_rebuilder_first_year (int yr) {i_rebuilder_st_yr = yr;}
    int rebuilder_first_year () {return i_rebuilder_st_yr;}
    void set_rebuilder_curr_year (int yr) {i_rebuilder_cur_yr = yr;}
    int rebuilder_curr_year () {return i_rebuilder_cur_yr;}
    void set_fleet_rel_f (int f) {i_fleet_rel_f = f;}
    int fleet_rel_f () {return i_fleet_rel_f;}
    void set_catch_tuning_basis (int basis) {i_ctch_basis = basis;}
    int catch_tuning_basis () {return i_ctch_basis;}

    void set_max_catch_fleet (int flt, int ctch);
    int num_fleets () {return i_max_catch_fleet.count();}
    int max_catch_fleet (int flt) {return i_max_catch_fleet.at(flt);}
    void set_max_catch_area (int ar, int ctch);
    int num_areas () {return i_max_catch_area.count();}
    int max_catch_area (int ar) {return i_max_catch_area.at(ar);}
    void set_alloc_group (int flt, int grp);
    int alloc_group (int flt) {return i_alloc_grp_list.at(flt);}
    int num_alloc_groups () {return i_num_alloc_groups;}
    void set_alloc_fraction (int grp, float frac) {f_alloc_grp_frac[grp] = frac;}
    int alloc_fraction (int grp) {return f_alloc_grp_frac.at(grp);}

    void set_num_catch_levels (int lvls) {i_num_fcast_ctch_levels = lvls;}
    int num_catch_levels () {return i_num_fcast_ctch_levels;}
    void set_input_catch_basis (int basis) {i_input_fcast_ctch_basis = basis;}
    int input_catch_basis () {return i_input_fcast_ctch_basis;}

    void add_fixed_catch_value (observation *obs);
    int num_catch_values () {return o_fixed_ctch_list.count();}
    observation *fixed_catch_value (int index){return o_fixed_ctch_list.at(index);}

    void clear();

 private:
    int   i_bmark;//1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy
    int   i_msy; //2 # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr)
    float f_spr_tgt; //0.4 # SPR target (e.g. 0.40)
    float f_bmass_tgt;//0.342 # Biomass target (e.g. 0.40)
    int   i_bmark_yrs[6];//#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF (enter actual year, or values of 0 or -integer to be rel. endyr)
    int   i_bmark_rel_f;//1 #Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
    int   i_method; //1 # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
    int   i_num_fcast_yrs;//10 # N forecast years
    float f_f_scalar;//0.2 # F scalar (only used for Do_Forecast==5)
    int   i_fcast_yrs[4];//#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF  (enter actual year, or values of 0 or -integer to be rel. endyr)
    int   i_ctl_rule_method;//1 # Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) )
    float f_ctl_rule_bmass_const_f;//    0.4 # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below)
    float f_ctl_rule_bmass_no_f;//0.1 # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10)
    float f_ctl_rule_tgt;//0.75 # Control rule target as fraction of Flimit (e.g. 0.75)
    int   i_num_fcast_loops;//3 #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
    int   i_fcast_loop_stch_recruit;//3 #_First forecast loop with stochastic recruitment
    int   i_fcast_loop_3;//0 #_Forecast loop control #3 (reserved for future bells&whistles)
    int   i_fcast_loop_4;//0 #_Forecast loop control #4 (reserved for future bells&whistles)
    int   i_fcast_loop_5;//0 #_Forecast loop control #5 (reserved for future bells&whistles)
    int   i_caps_st_year;//2010  #FirstYear for caps and allocations (should be after years with fixed inputs)
    float f_log_ctch_stdv;//0 # stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)
    bool  b_rebuilder;//0 # Do West Coast gfish rebuilder output (0/1)
    int   i_rebuilder_st_yr;//1999 # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
    int   i_rebuilder_cur_yr;//2002 # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
    int   i_fleet_rel_f;//1 # fleet relative F:  1=use first-last alloc year; 2=read seas(row) x fleet(col) below
    //# Note that fleet allocation is used directly as average F if Do_Forecast=4
    int   i_ctch_basis;//2 # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)
    //# Conditional input if relative F choice = 2
    //# Fleet relative F:  rows are seasons, columns are fleets
    //#_Fleet:  FISHERY1
    //#  1
    QList<QList<int> > i_seas_fleet_rel_f_list;
    //# max totalcatch by fleet (-1 to have no max) must enter value for each fleet
    QList<int> i_max_catch_fleet;// -1
    //# max totalcatch by area (-1 to have no max); must enter value for each fleet
    QList<int> i_max_catch_area;// -1
    //# fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)
    QList<int> i_alloc_grp_list;// 0
    int   i_num_alloc_groups;
    //#_Conditional on >1 allocation group
    //# allocation fraction for each of: 0 allocation groups
    QList<float> f_alloc_grp_frac;//
    //# no allocation groups
    int   i_num_fcast_ctch_levels;//0 # Number of forecast catch levels to input (else calc catch from forecast F)
    int   i_input_fcast_ctch_basis;//2 # basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F) (units are from fleetunits; note new codes in SSV3.20)
    //# Input fixed catch values
    //#Year Seas Fleet Catch(or_F)
    QList<observation *> o_fixed_ctch_list;

    void reset();
};

#endif // SS_FORECAST_H
