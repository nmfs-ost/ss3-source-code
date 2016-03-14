#ifndef MODEL_H
#define MODEL_H

#include <QObject>
#include <QCheckBox>
#include <QComboBox>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QLineEdit>



#include "fleet.h"
#include "population.h"
#include "ss_observation.h"
//#include "area.h"
#include "ss_forecast.h"
#include "block_pattern.h"
#include "sd_reporting.h"
#include "method_setup.h"

#include "tablemodel.h"
#include "tableview.h"
#include "spinboxdelegate.h"
#include "composition.h"

/** a class to keep data about seasons */
class Season : public QObject
{
    Q_OBJECT
public:
    explicit Season();
    ~Season() {}

public slots:
    void reset();
    int getNumMonths() const;
    void setNumMonths(int value);
    int getNumSubSeasons () const;
    void setNumSubSeasons(int value);

    bool getSpawning() const;
    void setSpawning(bool value);

private:
    int numMonths; /**< The number of months in this season */
    int numSubSeasons; /**< The number of sub seasons, always even */
    bool spawning;  /**< Whether spawning occurs in this season (only one per year) */
};


/** This is the main data class and holds pointers to all the other data classes */
class ss_model : public QWidget
{
    Q_OBJECT
public:
    explicit ss_model(QWidget *parent = 0);
    ~ss_model ();

    void clear();

    tablemodel *sdYearsModel;

    tablemodel *mbweightModel;
    QStringList mbweightHeader;

    QList<int> iSdValues;

    QList <Fleet *> fleets;
    population *  pPopulation;
    int  iNumAreas;
    ss_forecast *forecast;

public slots:
    void reset();

    void incrementYear ();

    Fleet *getFleet(int index);
    Fleet *newFleet (QString name = QString(""));
    Fleet *duplicateFleet (Fleet *oldfl);
    void addFleet (Fleet *flt);
    void deleteFleet (int index);
    population *getPopulation() {return pPopulation;}
    ss_forecast *getForecast() {return forecast;}

    void setReadMonths(bool flag) {readMonths = flag;}
    bool getReadMonths() {return readMonths;}

    void set_use_softbounds (int flag) {bUseSoftBounds = flag;}
    void set_use_softbounds (bool flag) {bUseSoftBounds = flag;}
    bool use_softbounds () {return bUseSoftBounds;}
    void set_prior_likelihood (int flag) {bPriorLikelihood = (flag == 1);}
    void set_prior_likelihood (bool flag) {bPriorLikelihood = flag;}
    bool prior_likelihood () {return bPriorLikelihood;}
    void set_last_estim_phase (int phase) {iLastEstimPhase = phase;}
    int last_estim_phase () {return iLastEstimPhase;}
    void set_mc_burn (int interval) {iMcBurn = interval;}
    int mc_burn () {return iMcBurn;}
    void set_mc_thin (int interval) {iMcThin = interval;}
    int mc_thin () {return iMcThin;}
    void set_jitter_param (double value) {dJitter = value;}
    double jitter_param () {return dJitter;}
    void set_bio_sd_min_year (int year) {iBioSdMinYr = year;}
    int bio_sd_min_year () {return iBioSdMinYr;}
    void set_bio_sd_max_year (int year) {iBioSdMaxYr = year;}
    int bio_sd_max_year () {return iBioSdMaxYr;}

    void set_num_std_years (int num_yrs);
    int num_std_years () {return sdYearsModel->columnCount();}
    void set_std_years_text (QString txt);
    void set_std_year (int index, QString year);
    QString std_year (int index) {return sdYearsModel->getRowData(0).at(index);}
    QString get_std_years_text ();

    void set_convergence_criteria (double value) {dConvergence = value;}
    double convergence_criteria () {return dConvergence;}

    void set_retrospect_year (int year) {iRetrospectYr = year;}
    int retrospect_year () {return iRetrospectYr;}
    void set_biomass_min_age (int age) {iBiomassMinAge = age;}
    int biomass_min_age () {return iBiomassMinAge;}
    void set_depletion_basis (int basis) {iDepletionBasis = basis;}
    int depletion_basis () {return iDepletionBasis;}
    void set_depletion_denom (double denom) {dDeplDenom = denom;}
    double depletion_denom () {return dDeplDenom;}
    void set_spr_basis (int basis) {iSprBasis = basis;}
    int spr_basis () {return iSprBasis;}
    void set_f_units (int units) {iFUnits = units;}
    int f_units () {return iFUnits;}
    void set_f_min_age (int age) {iFMinAge = age;}
    int f_min_age () {return iFMinAge;}
    void set_f_max_age (int age) {iFMaxAge = age;}
    int f_max_age () {return iFMaxAge;}
    void set_f_basis (int basis) {iFBasis = basis;}
    int f_basis () {return iFBasis;}

    void set_start_year (int year);
    int start_year () {return iStartYr;}
    void set_end_year (int year);
    int end_year () {return iEndYr;}
    int totalYears() {return iTotalYears;}
    void set_num_seasons (int seasns) ;
    Season *getSeason(int index);
    int getSeasonByMonth(float month);
    float getMonthBySeasonFleet(int seas, int fleet);
    int num_seasons () {return seasons.count();}
    void set_months_per_season (int seasn, int months);
    int months_per_season (int seasn) {return seasons.at(seasn)->getNumMonths();}
    int totalMonths();
    void set_spawn_season (int seasn) ;
    int spawn_season () ;
    int find_season (float month);
    float find_month (int fleet, int season);
    int totalSeasons();
    void set_num_subseasons(int value);
    int get_num_subseasons () const;
    void set_num_fisheries (int n_fisheries) {iNumFisheries = n_fisheries;}
    int num_fisheries ();
    void set_num_surveys (int n_surveys) {iNumSurveys = n_surveys;}
    int num_surveys ();
    void set_num_fleets (int n_fleets = 0);
    int num_fleets () {return fleets.count();}
    void assignFleetNumbers ();
    int getNumActiveFleets ();
    Fleet *getActiveFleet (int num);
    void set_num_areas (int n_areas);
    int num_areas () {return iNumAreas;}
    int getNumLinesCatch ();
    void add_fleet_catch_per_season (int fishery, int yr, int season, double num, double se = 0);
//    double fleet_catch_per_season (int fishery, int yr, int season);
    void setCatchMult (QStringList data) {catchMult->setRowData(0, data);}
    QStringList getCatchMult () {return catchMult->getRowData(0);}
    tablemodel *getCatchMultParam () {return catchMult;}
    void set_fleet_units_err_type (int fleet, int units, int err_type);
    int fleet_units (int fleet);
    int fleet_err_type (int fleet);
    void set_fleet_abundance (int fleet, int year, int month, float obs, float err);
    float fleet_abundance (int fleet, int year, int month);
    float fleet_abund_err (int fleet, int year, int month);
    void set_fleet_discard_units_err_type (int fleet, int units, int err_type);
    int fleet_discard_units (int fleet);
    int fleet_discard_err_type (int fleet);
    int fleet_discard_count();
    int fleet_discard_obs_count();
    void set_mean_body_wt_obs_count(int count) {mbweightModel->setRowCount(count);}
    int mean_body_wt_count () {return mbweightModel->rowCount();}
    tablemodel *getMeanBwtModel() {return mbweightModel;}
    void set_mean_body_wt_df (int df) {i_mean_bwt_df = df;}
    int mean_body_wt_df () {return i_mean_bwt_df;}
    void setMeanBwtObs (int index, QStringList data)
        {mbweightModel->setRowData(index, data);}
    QStringList getMeanBwtObs (int index) {return mbweightModel->getRowData(index);}

    void set_num_ages (int ages);
    int num_ages () {return iNumAges;}
    void set_num_genders (int genders);
    int num_genders () {return iNumGenders;}

    void set_run_number (int r_num) {iNumRuns = r_num;}
    int run_number () {return iNumRuns;}

    void set_length_composition (compositionLength *l_data) {lengthData = l_data;}
    compositionLength *get_length_composition () {return lengthData;}
    void set_age_composition (compositionAge *a_data) {ageData = a_data;}
    compositionAge *get_age_composition () {return ageData;}
    void set_morph_composition (compositionMorph *m_data) {morphData = m_data;}
    compositionMorph *get_morph_composition () {return morphData;}

    void set_num_environ_vars (int num) {obsEnvironVars->setNumVars(num);}
    int num_environ_vars () {return obsEnvironVars->getNumVars();}
    void set_num_environ_var_obs (int num) {obsEnvironVars->setNumObs(num);}
    int num_environ_var_obs () {return obsEnvironVars->getNumObs();}
    void add_environ_var_obs (QStringList txtlst);
    void set_environ_var_obs (int index, QStringList txtlst);
    QStringList get_environ_var_obs (int index) {return obsEnvironVars->getObservation(index);}
    tablemodel *getEnvVariables() {return obsEnvironVars->getObservations();}

    void set_num_general_comp_methods(int num);
    int num_general_comp_methods () {return cListGeneralMethods.count();}
    void add_general_comp_method (compositionGeneral *method) {cListGeneralMethods.append (method);}
    compositionGeneral *general_comp_method (int index) {return cListGeneralMethods.at(index);}

    void set_do_tags (bool flag) {doTags = flag;}
    bool get_do_tags () {return doTags;}
    void set_num_tag_groups (int num);
    int get_num_tag_groups () {return tagData->getNumTagGroups();}
    void set_tag_latency (int period) {tagData->setLatency(period);}
    int get_tag_latency () {return tagData->getLatency();}
    void set_tag_max_periods (int periods) {tagData->setMaxPeriods(periods);}
    int get_tag_max_periods () {return tagData->getMaxPeriods();}
    void set_tag_observation (int index, QStringList data) {tagData->setObservation(index, data);}
    QStringList get_tag_observation (int index) {return tagData->getObservation(index);}
    tablemodel *get_tag_observations () {return tagData->getObservations();}

    void set_do_morph_comp (bool flag) {doMorphComp = flag;}
    bool get_do_morph_comp () {return doMorphComp;}

    void setNumBlockPatterns (int num);// {iNumBlockPatterns = num;}
    int getNumBlockPatterns() {return iNumBlockPatterns;}
    void setBlockPattern (int index, BlockPattern *bp);
    void addBlockPattern (BlockPattern * bp) {blockPatterns.append (bp);}
    BlockPattern * getBlockPattern (int index) {return blockPatterns[index];}

    void setTagLoss(int flag);
    int getTagLoss() {return tag_loss;}
    void setTagLossParameter(longParameter *lp);
    void setTagLossParameter(QString text);
    longParameter *getTagLossParameter() {return tag_loss_param;}

    void setInputValueVariance (int flag) {i_input_variance = flag;}
    int getInputValueVariance () {return i_input_variance;}

    void setLambdaMaxPhase (int phs) {lambdaSetup.setA(phs);}
    int getLambdaMaxPhase () {return lambdaSetup.getA();}
    void setLambdaSdOffset (int sd) {lambdaSetup.setB(sd);}
    int getLambdaSdOffset () {return lambdaSetup.getB();}
    void setLambdaNumChanges(int num) {lambdaSetup.setC(num);}
    int getLambdaNumChanges();

    int getAddVariance() const;
    void setAddVariance(int value);
    void setAddVarSetupFromText (QString txt);
    QString getAddVarSetupToText ();
    void setAddVarSetupFleet(int val) {add_var_setup[0] = val;}
    int getAddVarSetupFleet () {return add_var_setup[0];}
    void setAddVarSetupLenAge(int val) {add_var_setup[1] = val;}
    int getAddVarSetupLenAge () {return add_var_setup[1];}
    void setAddVarSetupYear(int val) {add_var_setup[2] = val;}
    int getAddVarSetupYear () {return add_var_setup[2];}
    void setAddVarSetupNSlxBins(int val);
    int getAddVarSetupNSlxBins () {return add_var_setup[3];}
    void setAddVarSetupGPatt(int val) {add_var_setup[4] = val;}
    int getAddVarSetupGPatt () {return add_var_setup[4];}
    void setAddVarSetupNGAges(int val);
    int getAddVarSetupNGAges () {return add_var_setup[5];}
    void setAddVarSetupArNaa(int val) {add_var_setup[6] = val;}
    int getAddVarSetupArNaa () {return add_var_setup[6];}
    void setAddVarSetupYrNaa(int val) {add_var_setup[7] = val;}
    int getAddVarSetupYrNaa () {return add_var_setup[7];}
    void setAddVarSetupNaaBins(int val);
    int getAddVarSetupNaaBins () {return add_var_setup[8];}

    sd_reporting *getAddSdReporting () {return additionalSdReporting;}
    int getAddSdReprtActive() {return additionalSdReporting->getActive();}
    QStringList getAddSdReprtSetup () {return additionalSdReporting->getSpecs();}
    QStringList getAddSdReprtSelex () {return additionalSdReporting->getSelexBins();}
    QStringList getAddSdReprtGrwth () {return additionalSdReporting->getGrowthBins();}
    QStringList getAddSdReprtAtAge () {return additionalSdReporting->getNatAgeBins();}
    void setAddVarSelexBins (int index, float val);
    float getAddVarSelexBins (int index) {return add_var_slx_bins[index];}
    void setAddVarGrwthBins (int index, float val);
    float getAddVarGrwthBins (int index) {return add_var_age_bins[index];}
    void setAddVarNumAaBins (int index, float val);
    float getAddVarNumAaBins (int index) {return add_var_Naa_bins[index];}

    int checkyearvalue(int value);
    int refyearvalue(int value);

    int getCustomEnviroLink() const;
    void setCustomEnviroLink(int value);

    int getCustomBlockSetup() const;
    void setCustomBlockSetup(int value);

    int getCustomSelParmDevPhase() const;
    void setCustomSelParmDevPhase(int value);

    int getCustomSelParmDevAdjust() const;
    void setCustomSelParmDevAdjust(int value);

signals:
    void data_file_changed (QString fname);
    void control_file_changed (QString fname);


private:
    bool readMonths;
    bool bUseSoftBounds;
    bool bPriorLikelihood;
    int iLastEstimPhase;
    int iMcBurn;
    int iMcThin;
    double dJitter;
    int iBioSdMinYr;
    int iBioSdMaxYr;

    double dConvergence;
    int iRetrospectYr;
    int iBiomassMinAge;
    int iDepletionBasis;
    double dDeplDenom;
    int iSprBasis;

    int iFUnits;
    int iFMinAge;
    int iFMaxAge;
    int iFBasis;

    int iStartYr;
    int iEndYr;
    int iTotalYears;
    int iNumFisheries;
    int iNumSurveys;
    int i_num_predators;
    int iNumAges;
    int iNumGenders;

    int iNumRuns;

    int i_mean_bwt_df;

    parametermodel *catchMult;

    compositionLength *lengthData;
    compositionAge *ageData;
    QList<compositionGeneral *> cListGeneralMethods;
    bool doMorphComp;
    compositionMorph *morphData;

    environmentalVars *obsEnvironVars;
    bool doTags;
    tagObservation *tagData;

    QList<BlockPattern *> blockPatterns;
    int iNumBlockPatterns;

    sd_reporting *additionalSdReporting;

    QList <Season *> seasons;

    int tag_loss;
    longParameter *tag_loss_param;

    int i_input_variance;

    method_setup lambdaSetup;

    int i_add_variance;
    QList<int> add_var_setup;
    QList<float> add_var_slx_bins;
    QList<float> add_var_age_bins;
    QList<float> add_var_Naa_bins;

    int customEnviroLink;
    int customBlockSetup;
    int customSelParmDevPhase;
    int customSelParmDevAdjust;

};

double checkdoublevalue(QString value);
float checkfloatvalue(QString value);
int checkintvalue(QString value);

bool floatEquals (float a, float b);

#endif // MODEL_H
