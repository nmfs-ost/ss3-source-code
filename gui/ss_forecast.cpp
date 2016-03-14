#include "ss_forecast.h"

ss_forecast::ss_forecast(int fleets, int seasons, QObject *parent) :
    i_num_fleets(fleets), i_num_seasons(seasons), QObject (parent)
{
    o_fixed_ctch_list = new ssObservation();
    alloc_grp_frac = new tablemodel(this);
    // set defaults
    reset ();
    add_seas_fleet_rel_f(seasons, fleets, 0.0);
}

ss_forecast::~ss_forecast()
{
    clear();
}

void ss_forecast::set_combo_box_MSY(int msy)
{
    switch (msy)
    {
    case 0:
        set_MSY(1);
        break;
    case 1:
        set_MSY(2);
        break;
    case 2:
        set_MSY(3);
        break;
    case 3:
        set_MSY(4);
        break;
    default:
        set_MSY(1);
    }
}

void ss_forecast::set_combo_box_relf_basis(int relf)
{
    switch (relf)
    {
    case 0:
        set_benchmark_rel_f(1);
        break;
    case 1:
        set_benchmark_rel_f(2);
        break;
    default:
        set_benchmark_rel_f(1);
    }
}

void ss_forecast::set_combo_box_forecast(int fcast)
{
    set_forecast(fcast);
/*    switch (fcast)
    {
    case 0:
        set_forecast(0);
        break;
    default:
        set_forecast(0);
    }*/
}

void ss_forecast::set_num_forecast_years (int yrs)
{
    i_num_fcast_yrs = yrs;
    alloc_grp_frac->setRowCount(yrs);
}

void ss_forecast::set_combo_box_cr_method(int ctl)
{
    switch (ctl)
    {
    case 0:
        set_cr_method(1);
        break;
    case 1:
        set_cr_method(2);
        break;
    default:
        set_cr_method(1);
    }
}

void ss_forecast::set_combo_box_fleet_relf(int relf)
{
    switch (relf)
    {
    case 0:
        set_fleet_rel_f(1);
        break;
    case 1:
        set_fleet_rel_f(2);
        break;
    default:
        set_fleet_rel_f(1);
    }
}

void ss_forecast::set_combo_box_catch_tuning(int basis)
{
    switch (basis)
    {
    case 0:
        set_catch_tuning_basis(2);
        break;
    case 1:
        set_catch_tuning_basis(3);
        break;
    case 2:
        set_catch_tuning_basis(5);
        break;
    case 3:
        set_catch_tuning_basis(6);
        break;
    default:
        set_catch_tuning_basis(2);
    }
}

void ss_forecast::set_num_fleets(int flt)
{
    i_num_fleets = flt;
    int start = 0;
    if (!i_max_catch_fleet.isEmpty())
        start = i_max_catch_fleet.count();
    for (int i = start; i < flt; i++)
        i_max_catch_fleet.append(0);
    for (int i = flt; i < start; i++)
        i_max_catch_fleet.takeLast();
}

void ss_forecast::set_max_catch_fleet(int flt, int ctch)
{
    if (flt < i_max_catch_fleet.count())
        i_max_catch_fleet[flt] = ctch;
}

void ss_forecast::set_num_areas(int ars)
{
    int start = 0;
    if (!i_max_catch_area.isEmpty())
        start = i_max_catch_area.count();
    for (int i = start; i < ars; i++)
        i_max_catch_area.append(0);
    for (int i = ars; i < start; i++)
        i_max_catch_area.takeLast();
}

void ss_forecast::set_max_catch_area(int ar, int ctch)
{
    if (ar < i_max_catch_area.count())
        i_max_catch_area[ar] = ctch;
}

void ss_forecast::set_num_alloc_groups(int num)
{
    QStringList header;
    if (num != i_num_alloc_groups)
    {
        i_num_alloc_groups = num;
        alloc_grp_frac->setColumnCount(num);
        for (int i = 0; i < num; i++)
            header << QString("");
        alloc_grp_frac->setHeader(header);
    }
}

void ss_forecast::set_alloc_group(int flt, int grp)
{
    int i;
    for (i = i_alloc_grp_list.count(); i <= flt; i++)
        i_alloc_grp_list.append(0);
    i_alloc_grp_list[flt] = grp;

    if (grp > i_num_alloc_groups)
        set_num_alloc_groups(grp);
}

void ss_forecast::add_seas_fleet_rel_f (int seas, int flt, float f)
{
    int old_seas = 0, old_flt = 0, i = 0;
//    i_num_seasons = seas;
//    i_num_fleets = flt;
    if (!f_seas_fleet_rel_f_list.isEmpty())
        old_seas = f_seas_fleet_rel_f_list.count();
    for (i = 0; i < old_seas; i++)
    {
        QList<float> seas_list;
        for (int j = old_flt; j < flt; j++)
            seas_list.append(0);
        f_seas_fleet_rel_f_list.append(seas_list);
    }
    for (; i < seas; i++)
    {
        QList<float> seas_list;
        for (int j = 0; j < flt; j++)
            seas_list.append(0);
        f_seas_fleet_rel_f_list.append(seas_list);
    }
    f_seas_fleet_rel_f_list[seas-1][flt-1] = f;
}

void ss_forecast::set_combo_box_catch_input(int basis)
{
    switch (basis)
    {
    case 0:
        set_input_catch_basis(2);
        break;
    case 1:
        set_input_catch_basis(3);
        break;
    case 2:
        set_input_catch_basis(99);
        break;
    default:
        set_input_catch_basis(2);
    }
}

void ss_forecast::add_fixed_catch_value(QStringList txtlst)
{
    o_fixed_ctch_list->addObservation(txtlst);
}

void ss_forecast::reset()
{
    i_bmark = 1; // Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy
    i_msy = 2;   // MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr)
    f_spr_tgt = 0.45;  // SPR target (e.g. 0.40)
    f_bmass_tgt = 0.40;// Biomass target (e.g. 0.40)
    for (int i = 0; i < 6; i++)
        i_bmark_yrs[i] = 0;// Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF (enter actual year, or values of 0 or -integer to be rel. endyr)
    i_bmark_rel_f = 1; // Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
    i_method = 1;      // Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
    i_num_fcast_yrs = 10;// N forecast years
    f_f_scalar = 1.0;  // F scalar (only used for Do_Forecast==5)
    for (int i = 0; i < 4; i++)
        i_fcast_yrs[i] = 0;// Fcast_years:  beg_selex, end_selex, beg_relF, end_relF  (enter actual year, or values of 0 or -integer to be rel. endyr)
    i_ctl_rule_method = 1;// Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) )
    f_ctl_rule_bmass_const_f = 0.40;// Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below)
    f_ctl_rule_bmass_no_f = 0.10;// Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10)
    f_ctl_rule_tgt = 0.75;// Control rule target as fraction of Flimit (e.g. 0.75)
    i_num_fcast_loops = 3;// N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
    i_fcast_loop_stch_recruit = 3;// First forecast loop with stochastic recruitment
    i_fcast_loop_3 = 0;// Forecast loop control #3 (reserved for future bells&whistles)
    i_fcast_loop_4 = 0;// Forecast loop control #4 (reserved for future bells&whistles)
    i_fcast_loop_5 = 0;// Forecast loop control #5 (reserved for future bells&whistles)
    i_caps_st_year = 2015;// FirstYear for caps and allocations (should be after years with fixed inputs)
    f_log_ctch_stdv = 0.0;// stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)
    b_rebuilder = false;// Do West Coast gfish rebuilder output (0/1)
    i_rebuilder_st_yr = 2004;// Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
    i_rebuilder_cur_yr = -1;// Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
    i_fleet_rel_f = 1;// fleet relative F:  1=use first-last alloc year; 2=read seas(row) x fleet(col) below
    //# Note that fleet allocation is used directly as average F if Do_Forecast=4
    i_ctch_basis = 2;// basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)
    //# Conditional input if relative F choice = 2
    //# Fleet relative F:  rows are seasons, columns are fleets
    //#_Fleet:  FISHERY1
    //#  1
    reset_seas_fleet_relf();
    //# max totalcatch by fleet (-1 to have no max) must enter value for each fleet
    i_max_catch_fleet.clear();//
    i_max_catch_fleet.append(-1);
    //# max totalcatch by area (-1 to have no max); must enter value for each fleet
    i_max_catch_area.clear();//
    i_max_catch_area.append(-1);
    //# fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)
    i_alloc_grp_list.clear();//
    i_alloc_grp_list.append(0);
    set_num_alloc_groups(0);//
    //# no allocation groups
    i_num_fcast_ctch_levels = 0;// Number of forecast catch levels to input (else calc catch from forecast F)
    i_input_fcast_ctch_basis = 3;// basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F) (units are from fleetunits; note new codes in SSV3.20)
    //# Input fixed catch values
    //#Year Seas Fleet Catch(or_F)
/*    o_fixed_ctch_list.append(new ssObservation(0)); // make sure there's something to delete
    while(o_fixed_ctch_list.count() > 1)
    {
        ssObservation *obs = o_fixed_ctch_list.takeFirst();
        delete obs;
    }
    o_fixed_ctch_list[0]->fromText("2012 1 1 1200");*/
    o_fixed_ctch_list->setNumBins(0, 2);
    o_fixed_ctch_list->setNumObs(0);
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
    f_seas_fleet_rel_f_list.clear();
    i_max_catch_fleet.clear();
    i_max_catch_area.clear();
    i_alloc_grp_list.clear();
    i_num_alloc_groups = 0;
    i_num_fcast_ctch_levels = 0;
    i_input_fcast_ctch_basis = 0;
    o_fixed_ctch_list->setNumObs(0);
    alloc_grp_frac->setRowCount(0);
    set_num_alloc_groups(0);
}

void ss_forecast::reset_seas_fleet_relf()
{
    if (!f_seas_fleet_rel_f_list.isEmpty())
    {
        for (int i = 0; i < f_seas_fleet_rel_f_list.count(); i++)
            f_seas_fleet_rel_f_list[i].clear();
        f_seas_fleet_rel_f_list.clear();
    }

    for (int i = 0; i < i_num_seasons; i++)
    {
        QList<float> ql_f;
        for (int j = 0; j < i_num_fleets; j++)
        {
            ql_f.append(1.0);
        }
        f_seas_fleet_rel_f_list.append(ql_f);
    }
}

