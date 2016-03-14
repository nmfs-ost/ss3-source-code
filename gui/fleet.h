#ifndef FLEET_H
#define FLEET_H

#include <QObject>
#include <QStringList>

#include "area.h"
#include "yearindexmeasure.h"
#include "q.h"
#include "selectivity.h"
#include "method_setup.h"
#include "fleetlambda.h"
#include "tablemodel.h"
#include "ss_observation.h"
#include "fleet_composition.h"

class Fleet : public QObject
{
    Q_OBJECT
public:
    explicit Fleet(QObject *parent = 0);
    ~Fleet();

    void reset();
    Fleet * copy (Fleet *oldfl);

    enum FleetType {
        Fishing = 1,
        Bycatch,
        Survey,
        Predator,
        None
    };

signals:

public slots:
    // General
    void set_name(QString fname);
    QString get_name();
    void setNumber (int n) {i_number = n;}
    int getNumber () {return i_number;}
    bool getActive() const;
    bool isActive() const {return getActive();}
    void setActive(bool value);
    void setTypeInt (int type) {f_type = (FleetType)type;}
    int getTypeInt () {return (int)f_type;}
    void setType(FleetType ftype) {f_type = ftype;}
    FleetType getType() {return f_type;}
    void set_area(int farea) {i_area = farea;}
    int area() {return i_area;}
    void set_timing(double ftiming) {f_timing = (float)ftiming;}
    float timing() {return f_timing;}
    void setStartYear (int year) {i_start_year = year;}
    int getStartYear () {return i_start_year;}
    void setTotalYears (int n_years);
    int getTotalYears () {return i_num_years;}
    void set_num_seasons (int n_seasons);
    int get_num_seasons ();
    void setNumGenders (int num) {i_num_genders = num;}
    int getNumGenders () {return i_num_genders;}

    // catch
    void set_catch_units(int c_units) {i_catch_units = c_units;}
    int catch_units() {return i_catch_units;}
    void set_catch_se (double c_se) {d_catch_se_of_log = c_se;}
    double catch_se () {return d_catch_se_of_log;}
    void set_equ_catch_se(double c_se_eq) {d_catch_se_eq = c_se_eq;}
    double equ_catch_se() {return d_catch_se_eq;}
    void set_catch_mult (int mult) {i_catch_mult = mult;}
    int get_catch_mult () {return i_catch_mult;}

    void add_catch_per_season (int yr, int season, double value, double se);
    void set_catch_per_season (int index, int yr, int season, double value, double se) ;
//    double catch_per_season (int yr, int season) ;
    void set_catch_equil (double value) {d_catch_equil = value;}
    double catch_equil () {return d_catch_equil;}
    void setNumCatchObs (int rows) {retainCatch->setRowCount(rows);}
    int getNumCatchObs () {return retainCatch->rowCount();}
    void addCatchObservation (QStringList data);
    void setCatchObservation (int index, QStringList data);
    QStringList getCatchObservation(int index);
    tablemodel *getCatchModel() {return retainCatch;}

    // surveys
    void set_units(int unt) {i_units = unt;}           // 0=numbers, 1=biomass, 2=F
    int units() {return i_units;}           // 0=numbers, 1=biomass, 2=F
    void set_error_type(int err) {i_error_type = err;}      // -1=normal, 0=lognormal, >0=T
    int error_type() {return i_error_type;}      // -1=normal, 0=lognormal, >0=T

    // surveys
    void set_survey_units(int unt) {i_survey_units = unt;}
    int survey_units() {return i_survey_units;}
    void set_survey_error_type(int err) {i_survey_error_type = err;}
    int survey_error_type() {return i_survey_error_type;}

    // abundance
    int getYearMonthRow (tablemodel *tm, QString year, QString month);
    void setNumAbundObs (int num);
    void set_abundance(int year, int season, float obs);
    void setAbundMonth(int year, float month, float obs, float err);
    void addAbundByMonth(int year, float month, float obs, float err);
    float getAbundanceAmt(int year, float month);
    float getAbundanceErr(int year, float month);
    float abundance(int year, int month);
    void set_abundance_error(int year, int month, float err);
    float abundance_error(int year, int month);
    int abundance_count ();
    QStringList getAbundanceObs(int row);
    int getAbundanceCount();
    void setAbundanceObs (int index, QStringList data);
    void addAbundanceObs (QStringList data);
    tablemodel *getAbundanceModel () {return abundModel;}

    // discard
    void set_discard_units(int dis_unt) {i_discard_units = dis_unt;}   // 1=same_as_catchunits(bio/num), 2=fraction, 3=numbers
    int discard_units() {return i_discard_units;}
    void set_discard_err_type(int dis_err) {i_discard_errtype = dis_err;} // >0 for DF of T-dist(read CV below), 0 for normal with CV, -1 for normal_with_se() -2 for lognormal
    int discard_err_type() {return i_discard_errtype;}

    void setComboDiscardUnits (int code);
    int getComboDiscardUnits();
    void setNumDiscardObs (int num);
    void setDiscardMonth (int year, float month, float obs, float err);
    int getDiscardCount();
    void setDiscard (int i, QStringList data);
    void addDiscard (QStringList data);
    QStringList getDiscard (int row);
    float getDiscardObs (int year, float month);
    float getDiscardErr (int year, float month);
    tablemodel *getDiscardModel() {return discardModel;}

    // mean body weight data
    void setMbwtDF (int deg) {mbwtObs->setDegFreedom(deg);}
    int getMbwtDF () {return mbwtObs->getDegFreedom();}
    void setMbwtNumObs(int num) {mbwtObs->setNumObs(num);}
    int getMbwtNumObs() {return mbwtObs->getNumObs();}
    void addMbwtObservation (QStringList data) {setMbwtObservation(mbwtObs->getNumObs(), data);}
    void setMbwtObservation (int index, QStringList data) {mbwtObs->setObservation(index, data);}
    QStringList getMbwtObservation (int index) {return mbwtObs->getObservation(index);}
    tablemodel *getMbwtModel () {return mbwtObs->getObservations();}

    // sizecomp data
    void setLengthMinTailComp (QString value) {lengthComp->setMinTailComp(value.toFloat());}
    QString getLengthMinTailComp () {return QString::number(lengthComp->getMinTailComp());}
    void setLengthAddToData (QString value) {lengthComp->setAddToData(value.toFloat());}
    QString getLengthAddToData () {return QString::number(lengthComp->getAddToData());}
    void setLengthCombineGen (int bin) {lengthComp->setCombineGenders(bin);}
    int getLengthCombineGen () {return lengthComp->getCombineGenders();}
    void setLengthCompressBins (int bin) {lengthComp->setCompressBins(bin);}
    int getLengthCompressBins() {return lengthComp->getCompressBins();}
    void setLengthCompError (int type) {lengthComp->setErrorType(type);}
    int getLengthCompError () {return lengthComp->getErrorType();}
    void setLengthCompErrorParm (int val) {lengthComp->setErrorParam(val);}
    int getLengthCompErrorParm () {return lengthComp->getErrorParam();}
    void setLengthNumBins(int num) {lengthComp->setNumberBins(num, i_num_genders);}
    int getLengthObsLength () {return lengthComp->getObsLength();}
    void setLengthNumObs(int num) {lengthComp->setNumberObs(num);}
    int getLengthNumObs() {return lengthComp->getNumberObs();}
    void addLengthObservation (QStringList data) {setLengthObservation(lengthComp->getNumberObs(), data);}
    void setLengthObservation (int row, QStringList data) {lengthComp->setObservation(row, data);}
    QStringList getLengthObservation (int row) {return lengthComp->getObservation(row);}
    tablemodel *getLengthModel () {return lengthComp->getObsTable();}

    // agecomp data
    void setAgeMinTailComp (QString value) {ageComp->setMinTailComp(value.toFloat());}
    QString getAgeMinTailComp () {return QString::number(ageComp->getMinTailComp());}
    void setAgeAddToData (QString value) {ageComp->setAddToData(value.toFloat());}
    QString getAgeAddToData () {return QString::number(ageComp->getAddToData());}
    void setAgeCombineGen (int bin) {ageComp->setCombineGenders(bin);}
    int getAgeCombineGen () {return ageComp->getCombineGenders();}
    void setAgeCompressBins (int bin) {ageComp->setCompressBins(bin);}
    int getAgeCompressBins() {return ageComp->getCompressBins();}
    void setAgeCompError (int type) {ageComp->setErrorType(type);}
    int getAgeCompError () {return ageComp->getErrorType();}
    void setAgeCompErrorParm (int val) {ageComp->setErrorParam(val);}
    int getAgeCompErrorParm () {return ageComp->getErrorParam();}
    void setAgeNumBins(int num) {ageComp->setNumberBins(num, i_num_genders);}
    int getAgeObsLength () {return ageComp->getObsLength();}
    void setAgeNumObs(int num) {ageComp->setNumberObs(num);}
    int getAgeNumObs() {return ageComp->getNumberObs();}
    void addAgeObservation (QStringList data) {ageComp->addObservation(data);}
    void setAgeObservation (int row, QStringList data) {ageComp->setObservation(row, data);}
    QStringList getAgeObservation (int row) {return ageComp->getObservation(row);}
    tablemodel *getAgeModel () {return ageComp->getObsTable();}

    // saacomp data
    void setSaaNumBins(int num) {saaObs->setNumBins(num, i_num_genders);}
    void setSaaNumObs(int num) {saaObs->setNumObs(num);}
    int getSaaNumObs() {return saaObs->getNumObs();}
    void addSaaObservation (QStringList data) {saaObs->addObservation(data);}
    void setSaaObservation (int row, QStringList data) {saaObs->setObservation(row, data);}
    QStringList getSaaObservation (int row) {return saaObs->getObservation(row);}
    tablemodel *getSaaModel () {return saaObs->getObservations();}

    // general size data
    void setGenModelTotal(int num);
    int getGenModelTotal();
    void setGenMinTailComp (int index, QString value) {generalComps.at(index)->setMinTailComp(value.toFloat());}
    QString getGenMinTailComp (int index) {return QString::number(generalComps.at(index)->getMinTailComp());}
    void setGenAddToData (int index, QString value) {generalComps.at(index)->setAddToData(value.toFloat());}
    QString getGenAddToData (int index) {return QString::number(generalComps.at(index)->getAddToData());}
    void setGenCombineGen (int index, int bin) {generalComps.at(index)->setCombineGenders(bin);}
    int getGenCombineGen (int index) {return generalComps.at(index)->getCombineGenders();}
    void setGenCompressBins (int index, int bin) {generalComps.at(index)->setCompressBins(bin);}
    int getGenCompressBins(int index) {return generalComps.at(index)->getCompressBins();}
    void setGenCompError (int index, int type) {generalComps.at(index)->setErrorType(type);}
    int getGenCompError (int index) {return generalComps.at(index)->getErrorType();}
    void setGenCompErrorParm (int index, int val) {generalComps.at(index)->setErrorParam(val);}
    int getGenCompErrorParm (int index) {return generalComps.at(index)->getErrorParam();}
    void setGenNumBins (int index, int num) {generalComps.at(index)->setNumberBins(num, i_num_genders);}
    int getGenObsLength (int index) {return generalComps.at(index)->getObsLength();}
    void setGenNumObs (int index, int num) {generalComps.at(index)->setNumberObs(num);}
    int getGenNumObs (int index) {return generalComps.at(index)->getNumberObs();}
    void addGenObservation (int index, QStringList data);
    void setGenObservation (int index, int row, QStringList data);
    QStringList getGenObservation (int index, int row) {return generalComps.at(index)->getObservation(row);}
    tablemodel *getGenModel (int index) {return generalComps.at(index)->getObsTable();}

    // recapture data
    void setRecapNumEvents (int num) {recapObs->setNumRecapEvnts(num);}
    int getRecapNumEvents () {return recapObs->getNumRecapEvnts();}
    void addRecapObservation (QStringList data) {recapObs->addObservation(data);}
    void setRecapObservation (int row, QStringList data) {recapObs->setObservation(row, data);}
    QStringList getRecapObservation (int row) {return recapObs->getObservation(row);}
    tablemodel *getRecapModel () {return recapObs->getObservations();}

    // morph data
    void setMorphMinTailComp (QString value) {morphComp->setMinTailComp(value.toFloat());}
    QString getMorphMinTailComp () {return QString::number(morphComp->getMinTailComp());}
    void setMorphAddToData (QString value) {morphComp->setAddToData(value.toFloat());}
    QString getMorphAddToData () {return QString::number(morphComp->getAddToData());}
    void setMorphCombineGen (int bin) {morphComp->setCombineGenders(bin);}
    int getMorphCombineGen () {return morphComp->getCombineGenders();}
    void setMorphCompressBins (int bin) {morphComp->setCompressBins(bin);}
    int getMorphCompressBins() {return morphComp->getCompressBins();}
    void setMorphCompError (int type) {morphComp->setErrorType(type);}
    int getMorphCompError () {return morphComp->getErrorType();}
    void setMorphCompErrorParm (int val) {morphComp->setErrorParam(val);}
    int getMorphCompErrorParm () {return morphComp->getErrorParam();}
    void setMorphNumMorphs (int num) {morphComp->setNumberMorphs(num);}
    int getMorphObsLength () {return morphComp->getObsLength();}
    void setMorphNumObs (int num) {morphComp->setNumberObs(num);}
    int getMorphNumObs () {return morphComp->getNumberObs();}
    void addMorphObservation (QStringList data) {morphComp->addObservation(data);}
    void setMorphObservation (int row, QStringList data) {morphComp->setObservation(row, data);}
    QStringList getMorphObservation (int row) {return morphComp->getObservation(row);}
    tablemodel *getMorphModel () {return morphComp->getObsTable();}

    //  #q_section
    void set_q_do_power(int den) {Q()->setDoPower(den);}
    void set_q_do_power(bool yes) {Q()->setDoPower(yes?1:0);}
    int q_do_power() {return Q()->getDoPower();}
    void set_q_do_env_lnk(int env_vr) {Q()->setDoEnvLink(env_vr);}
    void set_q_do_env_lnk(bool yes) {Q()->setDoEnvLink(yes?1:0);}
    int q_do_env_lnk() {return Q()->getDoEnvLink();}
    void set_q_do_extra_sd(int ext_sd) {Q()->setDoExtraSD(ext_sd);}
    void set_q_do_extra_sd(bool yes) {Q()->setDoExtraSD(yes?1:0);}
    int q_do_extra_sd() {return Q()->getDoExtraSD();}
    void set_q_type(int qt) {Q()->setType(qt);}
    int q_type() {return Q()->getType();}
    parametermodel *getQParams() {return Q()->getModel();}

    q_ratio *Q() {return q_R;}

    //   #size selex
    selectivity* getSizeSelectivity() {return size_selex;}
    void set_size_selex_pattern(int ss_pat) {size_selex->setPattern(ss_pat);}
    int size_selex_pattern() {return size_selex->getPattern();}
    void set_size_selex_discard(int ss_dis) {size_selex->setDiscard(ss_dis);}
    int size_selex_discard() {return size_selex->getDiscard();}
    void set_size_selex_male(bool ss_m) {size_selex->setMale(ss_m);}
    bool size_selex_male() {return size_selex->getMale();}
    void set_size_selex_special(int ss_spec) {size_selex->setSpecial(ss_spec);}
    int size_selex_special() {return size_selex->getSpecial();}
    parametermodel *getSizeSelexModel() {return size_selex->getParameterModel();}

    //   #age selex
    selectivity* getAgeSelectivity() {return age_selex;}
    void set_age_selex_pattern(int as_pat) {age_selex->setPattern(as_pat);}
    int age_selex_pattern() {return age_selex->getPattern();}
    void set_age_selex_gt_lt(int as_glt) {age_selex->setDiscard(as_glt);}
    int age_selex_gt_lt() {return age_selex->getDiscard();}
    void set_age_selex_male(bool as_m) {age_selex->setMale(as_m);}
    bool age_selex_male() {return age_selex->getMale();}
    void set_age_selex_special(int as_spec) {age_selex->setSpecial(as_spec);}
    int age_selex_special() {return age_selex->getSpecial();}
    parametermodel *getAgeSelexModel() {return age_selex->getParameterModel();}

    void setAddToSurveyCV (float val) {add_to_survey_CV = val;}
    float getAddToSurveyCV () {return add_to_survey_CV;}
    void setAddToDiscardSD (float val) {add_to_discard_stddev = val;}
    float getAddToDiscardSD () {return add_to_discard_stddev;}
    void setAddToBodyWtCV (float val) {add_to_bodywt_CV = val;}
    float getAddToBodyWtCV () {return add_to_bodywt_CV;}
    void setMultByLenCompN (float val) {mult_by_lencomp_N = val;}
    float getMultByLenCompN () {return mult_by_lencomp_N;}
    void setMultByAgeCompN (float val) {mult_by_agecomp_N = val;}
    float getMultByAgeCompN () {return mult_by_agecomp_N;}
    void setMultBySAA (float val) {mult_by_saa_N = val;}
    float getMultBySAA () {return mult_by_saa_N;}

    void resetLambdas() {setNumLambdas(0);}
    void setNumLambdas(int rows) {lambdaModel->setRowCount(rows);}
    int getNumLambdas() {return lambdaModel->rowCount();}
    void appendLambda (QStringList values);
    QStringList getLambda(int row) {return lambdaModel->getRowData(row);}
    tablemodel *getLambdaModel() {return lambdaModel;}


protected:
    QString *s_name;
    bool active;
    int i_number;
    FleetType f_type;
    int i_area;
    float f_timing;
    int i_num_years;
    int i_start_year;
    int i_num_seasons;
    int i_num_genders;

    // catch
    int i_catch_units;
    double d_catch_se_eq;
    double d_catch_se_of_log;
    int i_catch_mult;

    tablemodel *retainCatch;
    QStringList catchHeader;

    tablemodel *abundModel;
    QStringList abundanceHeader;

    tablemodel *discardModel;
    QStringList discardHeader;

    fleet_comp_length *lengthComp;
    fleet_comp_age *ageComp;
    fleet_comp_morph *morphComp;
    QList<fleet_comp_general*> generalComps;

    meanBwtObservation *mbwtObs;
//    lengthObservation *lengthObs;
//    ageObservation *ageObs;
    saaObservation *saaObs;
//    QList<generalObservation*> genObs;
    recapObservation *recapObs;
//    morphObservation *morphObs;

    tablemodel *lambdaModel;

    QList<yearIndexMeasure*> d_catch;
    double d_catch_equil;

    // surveys
    int i_units;           // 0=numbers, 1=biomass, 2=F
    int i_error_type;      // -1=normal, 0=lognormal, >0=T

    // discard
    int i_discard_units;   // 1=same_as_catchunits(bio/num), 2=fraction, 3=numbers
    int i_discard_errtype; // >0 for DF of T-dist(read CV below), 0 for normal with CV, -1 for normal with se -2 for lognormal

    QList<yearIndexMeasure*> d_discard;
    QList<yearIndexMeasure*> d_discard_err;

    //   size selex
    selectivity *size_selex;

    //   age selex
    selectivity *age_selex;

    int i_survey_units;
    int i_survey_error_type;
    QList<yearIndexMeasure*> f_abundance;
    QList<yearIndexMeasure*> f_abundance_error;

    q_ratio * q_R;

    float add_to_survey_CV;
    float add_to_discard_stddev;
    float add_to_bodywt_CV;
    float mult_by_lencomp_N;
    float mult_by_agecomp_N;
    float mult_by_saa_N;

    QList<fleetLambda> lambdas;

};

#endif // FLEET_H
