#include "fleet.h"
#include "model.h"

Fleet::Fleet(QObject *parent) :
    QObject(parent)
{
    ss_model *model = static_cast<ss_model*>(parent);
    i_start_year = model->start_year();

    retainCatch = new tablemodel(this);
    retainCatch->setColumnCount(4);
    catchHeader << "Year" << "Season" << "Catch" << "Catch_Se";
    retainCatch->setHeader(catchHeader);

    abundModel = new tablemodel (this);
    abundModel->setColumnCount(4);
    abundanceHeader << "Year" << "Season" << "Value" << "Std. err of log";
    abundModel->setHeader(abundanceHeader);

    discardModel = new tablemodel (this);
    discardModel->setColumnCount(4);
    discardHeader << "Year" << "Season" << "Observation" << "Error";
    discardModel->setHeader(discardHeader);

    mbwtObs = new meanBwtObservation();
    lengthComp = new fleet_comp_length(this);
    ageComp = new fleet_comp_age(this);
//    ageObs = new ageObservation();
    saaObs = new saaObservation();
    recapObs = new recapObservation();
//    genObs.append(0);
//    genObs.clear();
    generalComps.append(0);
    generalComps.clear();
    morphComp = new fleet_comp_morph(this);
//    morphObs = new morphObservation();


    lambdaModel = new tablemodel (this);
    lambdaModel->setColumnCount(4);
    abundanceHeader.clear();
    abundanceHeader << "Component" << "Phase" << "Lambda" << "SizeFreq";
    lambdaModel->setHeader(abundanceHeader);

    q_R = new q_ratio();
    s_name = NULL;
    size_selex = new selectivity();
    age_selex = new selectivity();
    reset();
}

Fleet::~Fleet()
{
    reset();
    if (s_name != NULL)
        delete s_name;
    s_name = NULL;
    if (retainCatch != NULL)
        delete retainCatch;
    retainCatch = NULL;
    if (abundModel != NULL)
        delete abundModel;
    abundModel = NULL;
    if (discardModel != NULL)
        delete discardModel;
    discardModel = NULL;
    if (lengthComp != NULL)
        delete lengthComp;
    lengthComp = NULL;
    if (ageComp != NULL)
        delete ageComp;
    ageComp = NULL;
    if (morphComp != NULL)
        delete morphComp;
    morphComp = NULL;
    while (generalComps.count() > 0)
    {
        fleet_comp_general*cg = generalComps.takeLast();
        delete cg;
        cg = NULL;
    }
    if (mbwtObs != NULL)
        delete mbwtObs;
    mbwtObs = NULL;
    if (saaObs != NULL)
        delete saaObs;
    saaObs = NULL;
    if (recapObs != NULL)
        delete recapObs;
    recapObs = NULL;
    if (lambdaModel != NULL)
        delete lambdaModel;
    lambdaModel = NULL;

    delete size_selex;
    size_selex = NULL;
    delete age_selex;
    age_selex = NULL;

    delete q_R;
    q_R = NULL;
    lambdas.clear();
}

void Fleet::set_name(QString fname)
{
    if (s_name == NULL)
        s_name = new QString("");

    s_name->clear();
    s_name->append(fname);
}

QString Fleet::get_name()
{
    QString nm("");
    if (s_name == NULL)
        nm.append("None");
    else
        nm.append(*s_name);
    return nm;
}

void Fleet::reset()
{
    set_name(QString("new_fleet"));
    setNumber(1);
    setActive(true);
    setType(Fleet::Fishing);
    set_area(1);
    set_timing(0.5);
    setTotalYears(1);
    set_num_seasons(1);
    setNumGenders(2);

    // catch
    set_catch_units(2);
    set_equ_catch_se(0.1);
    set_catch_se(0.1);
    set_catch_mult(0);
    set_catch_equil(0.0);
    setNumCatchObs(0);

    // surveys
    set_units(0);
    set_error_type(0);
    set_survey_units(0);
    set_survey_error_type(0);

    // abundance
    setNumAbundObs(0);

    // discard
    set_discard_units(0);
    set_discard_err_type(0);
    setNumDiscardObs(0);

    // mean bwt
    setMbwtDF(0);
    setMbwtNumObs(0);

    // sizecomp data
    setLengthMinTailComp("0.0");
    setLengthAddToData("0.0");
    setLengthCombineGen(0);
    setLengthCompressBins(0);
    setLengthCompError(0);
    setLengthCompErrorParm(0);
    setLengthNumObs(0);
    setLengthNumBins(0);

    // agecomp data
    setAgeMinTailComp("0.0");
    setAgeAddToData("0.0000001");
    setAgeCombineGen(0);
    setAgeCompressBins(0);
    setAgeCompError(0);
    setAgeCompErrorParm(0);
    setAgeNumObs(0);
    setAgeNumBins(0);
    ageComp->set_num_error_defs(0);

    // saa data
    setSaaNumObs(0);
    setSaaNumBins(0);

    // general size data
    while (generalComps.count() > 0)
    {
        fleet_comp_general*cg = generalComps.takeLast();
        cg->setNumberObs(0);
        delete cg;
    }
    setGenModelTotal(0);

    // recapture data
    setRecapNumEvents(0);

    // morph data
    setMorphMinTailComp("0.0");
    setMorphAddToData("0.0");
    setMorphCombineGen(0);
    setMorphCompressBins(0);
    setMorphCompError(0);
    setMorphCompErrorParm(0);
    setMorphNumObs(0);
    setMorphNumMorphs(0);

    //  q_section
    q_R->reset();

    //   size selex
    size_selex->setPattern(0);

    //   age selex
    age_selex->setPattern(0);

    // Variance
    add_to_survey_CV = 0;
    add_to_discard_stddev = 0;
    add_to_bodywt_CV = 0;
    mult_by_lencomp_N = 1;
    mult_by_agecomp_N = 1;
    mult_by_saa_N = 1;

    resetLambdas();
}

Fleet *Fleet::copy(Fleet *oldfl)
{
    ss_model *model = static_cast<ss_model*>(oldfl->parent());
    int i;
    set_name (QString("%1_Copy").arg(oldfl->get_name()));
    setActive(true);
    setNumber(oldfl->getNumber());
    setType (oldfl->getType());
    set_area(oldfl->area());
    set_timing(oldfl->timing());
    setStartYear(oldfl->getStartYear());
    setTotalYears(oldfl->getTotalYears());
    set_num_seasons(oldfl->get_num_seasons());

    // catch
    set_catch_units(oldfl->catch_units());
    set_catch_se(oldfl->catch_se());
    set_equ_catch_se(oldfl->equ_catch_se());
    set_catch_equil(oldfl->catch_equil());
    set_catch_mult(oldfl->get_catch_mult());
    setNumCatchObs(oldfl->getNumCatchObs());
    for (int i = 0; i < retainCatch->rowCount(); i++)
        setCatchObservation(i, oldfl->getCatchObservation(i));

    // surveys
    set_units(oldfl->units());
    set_error_type(oldfl->error_type());

    set_survey_units(oldfl->survey_units());
    set_survey_error_type(oldfl->survey_error_type());

    // abundance
    setNumAbundObs(oldfl->getAbundanceCount());
    for (i = 0; i < abundModel->rowCount(); i++)
        setAbundanceObs(i, oldfl->getAbundanceObs(i));

    // discard
    set_discard_units(oldfl->discard_units());
    set_discard_err_type(oldfl->discard_err_type());
    setNumDiscardObs(oldfl->getDiscardCount());
    for (i = 0; i < discardModel->rowCount(); i++)
        setDiscard(i, oldfl->getDiscard(i));

    // mean bwt
    setMbwtDF(oldfl->getMbwtDF());
    setMbwtNumObs(oldfl->getMbwtNumObs());
    for (i = 0; i < getMbwtNumObs(); i++)
        setMbwtObservation(i, oldfl->getMbwtObservation(i));

    // sizecomp data
    setLengthMinTailComp(oldfl->getLengthMinTailComp());
    setLengthAddToData(oldfl->getLengthAddToData());
    setLengthCombineGen(oldfl->getLengthCombineGen());
    setLengthCompressBins(oldfl->getLengthCompressBins());
    setLengthCompError(oldfl->getLengthCompError());
    setLengthCompErrorParm(oldfl->getLengthCompErrorParm());
    setLengthNumBins(model->get_length_composition()->getNumberBins());
    setLengthNumObs(oldfl->getLengthNumObs());
    for (i = 0; i < getLengthNumObs(); i++)
        setLengthObservation(i, oldfl->getLengthObservation(i));

    // agecomp data
    setAgeMinTailComp(oldfl->getAgeMinTailComp());
    setAgeAddToData(oldfl->getAgeAddToData());
    setAgeCombineGen(oldfl->getAgeCombineGen());
    setAgeCompressBins(oldfl->getAgeCompressBins());
    setAgeCompError(oldfl->getAgeCompError());
    setAgeCompErrorParm(oldfl->getAgeCompErrorParm());
    setAgeNumBins(model->get_age_composition()->getNumberBins());
    setAgeNumObs(oldfl->getAgeNumObs());
    for (i = 0; i < getAgeNumObs(); i++)
        setAgeObservation(i, oldfl->getAgeObservation(i));

    // saa data
    setSaaNumBins(model->get_age_composition()->getNumberBins());
    setSaaNumObs(oldfl->getSaaNumObs());
    for (i = 0; i < getSaaNumObs(); i++)
        setSaaObservation(i, oldfl->getSaaObservation(i));

    // general size data
    setGenModelTotal(oldfl->getGenModelTotal());
    for (int mod = 0; mod < getGenModelTotal(); mod++)
    {
        setGenMinTailComp(mod, oldfl->getGenMinTailComp(mod));
        setGenAddToData(mod, oldfl->getGenAddToData(mod));
        setGenCombineGen(mod, oldfl->getGenCombineGen(mod));
        setGenCompressBins(mod, oldfl->getGenCompressBins(mod));
        setGenCompError(mod, oldfl->getGenCompError(mod));
        setGenCompErrorParm(mod, oldfl->getGenCompErrorParm(mod));
        setGenNumBins(mod, model->general_comp_method(mod)->getNumberBins());
        setGenNumObs(mod, oldfl->getGenNumObs(mod));
        for (i = 0; i < getGenNumObs(mod); i++)
            setGenObservation(mod, i, oldfl->getGenObservation(mod, i));
    }

    // recapture data
    setRecapNumEvents(oldfl->getRecapNumEvents());
    for (i = 0; i < getRecapNumEvents(); i++)
        setRecapObservation(i, oldfl->getRecapObservation(i));

    // morph data
    if (model->get_do_morph_comp())
    {
        setMorphMinTailComp(oldfl->getMorphMinTailComp());
        setMorphAddToData(oldfl->getMorphAddToData());
        setMorphCombineGen(oldfl->getMorphCombineGen());
        setMorphCompressBins(oldfl->getMorphCompressBins());
        setMorphCompError(oldfl->getMorphCompError());
        setMorphCompErrorParm(oldfl->getMorphCompErrorParm());
        setMorphNumMorphs(model->get_morph_composition()->getNumberMorphs());
        setMorphNumObs(oldfl->getMorphNumObs());
        for (i = 0; i < getMorphNumObs(); i++)
            setMorphObservation(i, oldfl->getMorphObservation(i));
    }

    //  q_section
    set_q_do_power(oldfl->q_do_power());
    set_q_do_env_lnk(oldfl->q_do_env_lnk());
    set_q_do_extra_sd(oldfl->q_do_extra_sd());
    set_q_type(oldfl->q_type());
    for (i = 0; i < oldfl->Q()->getNumParams(); i++)
        Q()->setParameter(i, oldfl->Q()->getParameter(i));

    //   size selex
    set_size_selex_pattern(oldfl->size_selex_pattern());
    set_size_selex_discard(oldfl->size_selex_discard());
    set_size_selex_male(oldfl->size_selex_male());
    set_size_selex_special(oldfl->size_selex_special());
    size_selex->setPattern(size_selex_pattern());
    for (i = 0; i < oldfl->getSizeSelectivity()->getNumParameters(); i++)
        size_selex->setParameter(i, oldfl->getSizeSelectivity()->getParameterModel()->getRowData(i));

    //   age selex
    set_age_selex_pattern(oldfl->age_selex_pattern());
    set_age_selex_gt_lt(oldfl->age_selex_gt_lt()); // <>
    set_age_selex_male(oldfl->age_selex_male());
    set_age_selex_special(oldfl->age_selex_special());
    age_selex->setPattern(age_selex_pattern());
    for (i = 0; i < oldfl->getAgeSelectivity()->getNumParameters(); i++)
        age_selex->setParameter(i, oldfl->getAgeSelectivity()->getParameterModel()->getRowData(i));

    // lambdas
    {
        int lams = oldfl->getNumLambdas();
        setNumLambdas(0);
        for (i = 0; i < lams; i++)
        {
            appendLambda(oldfl->getLambda(i));
        }
    }

    return this;
}

void Fleet::setTotalYears(int n_years)
{
    i_num_years = n_years;
}
void Fleet::add_catch_per_season(int yr, int seas, double value, double se)
{
    int index = retainCatch->rowCount();
    set_catch_per_season(index, yr, seas, value, se);
}

void Fleet::set_catch_per_season(int index, int yr, int seas, double value, double se)
{
    QVector<double> rowdata;
    rowdata.append((double)yr);
    rowdata.append((double)seas);
    rowdata.append(value);
    rowdata.append(se);

    if (retainCatch->rowCount() <= index)
        retainCatch->setRowCount(index + 1);

    retainCatch->setRowData(index, rowdata);
}


void Fleet::addCatchObservation(QStringList data)
{
    int index = retainCatch->rowCount();
    setCatchObservation(index, data);
}

void Fleet::setCatchObservation(int index, QStringList data)
{
    if (retainCatch->rowCount() <= index)
        retainCatch->setRowCount(index + 1);
    retainCatch->setRowData(index, data);
}

QStringList Fleet::getCatchObservation (int index)
{
    return retainCatch->getRowData(index);
}


void Fleet::setComboDiscardUnits(int code)
{
    switch (code)
    {
    case 0:
        i_discard_units = 1;
        break;
    case 1:
        i_discard_units = 2;
        break;
    case 2:
        i_discard_units = 3;
    case 3:
    default:
        i_discard_units = -1;
    }
}
int Fleet::getComboDiscardUnits()
{
    int code;
    switch (i_discard_units)
    {
    default:
    case 1:
        code = 0;
        break;
    case 2:
        code = 1;
        break;
    case 3:
        code = 2;
        break;
    }
    return code;
}

void Fleet::setNumDiscardObs (int num)
{
    discardModel->setRowCount(num);
}

void Fleet::setDiscardMonth (int year, float month, float obs, float err)
{
    QString yr(QString::number(year));
    QString mo(QString::number(month));
    int row = getYearMonthRow(discardModel, yr, mo);
    QStringList values;
    values << yr << mo << QString::number(obs) << QString::number(err);
    discardModel->setRowData(row, values);
}

int Fleet::getDiscardCount ()
{
    return discardModel->rowCount();
}

void Fleet::setDiscard(int i, QStringList data)
{
    if (i >= getDiscardCount())
        discardModel->setRowCount(i+1);
    discardModel->setRowData(i, data);
}

void Fleet::addDiscard(QStringList data)
{
    setDiscard(getDiscardCount(), data);
}

QStringList Fleet::getDiscard (int row)
{
    QStringList values(discardModel->getRowData(row));
    return values;
}

float Fleet::getDiscardObs (int year, float month)
{
    QString yr(QString::number(year));
    QString mo(QString::number(month));
    int row = getYearMonthRow(discardModel, yr, mo);
    QStringList values(discardModel->getRowData(row));
    return values.at(2).toFloat();
}

float Fleet::getDiscardErr (int year, float month)
{
    QString yr(QString::number(year));
    QString mo(QString::number(month));
    int row = getYearMonthRow(discardModel, yr, mo);
    QStringList values(discardModel->getRowData(row));
    return values.at(3).toFloat();
}

void Fleet::setGenModelTotal(int num)
{
    while (getGenModelTotal() < num)
        generalComps.append(new fleet_comp_general(this));
    while (num < getGenModelTotal())
        delete generalComps.takeLast();
}

int Fleet::getGenModelTotal()
{
    int num = 0;
    if (!generalComps.isEmpty())
        num = generalComps.count();
    return num;
}

void Fleet::addGenObservation(int index, QStringList data)
{
    generalComps.at(index)->addObservation(data);
}

void Fleet::setGenObservation(int index, int row, QStringList data)
{
    generalComps.at(index)->setObservation(row, data);
}

void Fleet::set_num_seasons(int n_seasons)
{
    i_num_seasons = n_seasons;
}

int Fleet::get_num_seasons()
{
    return i_num_seasons;
}

int Fleet::getYearMonthRow(tablemodel *tm, QString year, QString month)
{
    int row;
    for (row = 0; row < tm->rowCount(); row++)
    {
        QStringList check (tm->getRowData(row));
        if (check.at(0) == year)
        {
            if (check.at(1) == month)
                break;
        }
    }
    if (row == tm->rowCount())
        tm->setRowCount(row + 1);
    return row;
}

void Fleet::setNumAbundObs(int num)
{
    abundModel->setRowCount(num);
}

void Fleet::addAbundanceObs(QStringList data)
{
    setAbundanceObs(getAbundanceCount(), data);
}

void Fleet::setAbundanceObs(int index, QStringList data)
{
    if (abundModel->rowCount() <= index)
        abundModel->setRowCount(index + 1);
    abundModel->setRowData(index, data);
}

QStringList Fleet::getAbundanceObs(int row)
{
    return abundModel->getRowData(row);
}

void Fleet::addAbundByMonth(int year, float month, float obs, float err)
{
    int index = getAbundanceCount();
    QStringList values;
    values << QString::number(year);
    values << QString::number(month);
    values << QString::number(obs);
    values << QString::number(err);
    setAbundanceObs(index, values);
}

void Fleet::setAbundMonth(int year, float month, float obs, float err)
{
    QStringList values;
    int row = (year - i_start_year) * i_num_seasons + (int)month;
    values << QString::number(year);
    values << QString::number(month);
    values << QString::number(obs);
    values << QString::number(err);
//    row = getYearMonthRow(abundModel, values.at(0), values.at(1));
    setAbundanceObs(row, values);
}

void Fleet::set_abundance(int year, int season, float obs)
{
    yearIndexMeasure *yim = getYearIndexMeasure(f_abundance, year, season);
    yim->setValue(obs);
}

float Fleet::abundance(int year, int month)
{
    double val = 0.0;
    yearIndexMeasure *yim = NULL;
    yim = getYearIndexMeasure(f_abundance, year, month);
    if (yim)
        val = yim->getValue();
    return val;
}

void Fleet::set_abundance_error(int i_year, int month, float err)
{
    yearIndexMeasure *yim = getYearIndexMeasure(f_abundance_error, i_year, month);

    yim->setValue(err);
}

float Fleet::abundance_error(int year, int month)
{
    double val = 0.0;
    yearIndexMeasure *yim = NULL;
    yim = getYearIndexMeasure(f_abundance_error, year, month);
    if (yim)
        val = yim->getValue();
    return val;
}

int Fleet::getAbundanceCount()
{
    return abundModel->rowCount();
}

float Fleet::getAbundanceAmt(int yr, float mn)
{

}

float Fleet::getAbundanceErr(int yr, float mn)
{

}

int Fleet::abundance_count()
{
    int count = 0;
    QStringList values;
    for (int i = 0; i < abundModel->rowCount(); i++)
    {
        values = abundModel->getRowData(i);
        if (!values.at(0).isEmpty())
        {
            if (values.at(2).toFloat() > 0.0001)
                count ++;
        }
    }
    return count;
/*    int count = 0;
    yearIndexMeasure *yim = NULL;
    for (int i = 0; i < f_abundance.count(); i++)
    {
        yim = f_abundance.at(i);
        if (yim->getValue() > 0.0001)
            count ++;
    }
    return count;*/
}
/*
void Fleet::resetLambdas()
{
    if (!lambdas.isEmpty())
        lambdas.clear();
    numLambdas = 0;
}

void Fleet::setLambda (int cmp, int phs, float lmb, int szfq)
{
    bool append = true;

    fleetLambda lamb (cmp, phs, lmb, szfq);
    fleetLambda cur;

    if (numLambdas > 0)
    {
        for (int i = 0; i < numLambdas; i++)
        {
            cur = lambdas.at(i);
            if (cur == lamb)
            {
                append = false;
                break;
            }
        }
    }
    if (append)
    {
        lambdas.append(lamb);
        numLambdas = lambdas.count();
    }

}

void Fleet::setLambdaComponent (int index, int cmp)
{
    if (index >= 0 && index < numLambdas)
    {
        lambdas[index].setComponent(cmp);
    }
}

int Fleet::getLambdaComponent (int index)
{
    int cmp = 0;
    if (index >= 0 && index < numLambdas)
    {
        cmp = lambdas[index].getComponent();
    }
    return cmp;
}

void Fleet::setLambdaPhase (int index, int phs)
{
    if (index >= 0 && index < numLambdas)
    {
        lambdas[index].setPhase(phs);
    }
}

int Fleet::getLambdaPhase (int index)
{
    int phs = -1;
    if (index >= 0 && index < numLambdas)
    {
        phs = lambdas[index].getPhase();
    }
    return phs;
}

void Fleet::setLambdaValue (int index, float lmb)
{
    if (index >= 0 && index < numLambdas)
    {
        lambdas[index].setLambda(lmb);
    }
}

float Fleet::getLambdaValue (int index)
{
    float val = 1.0;
    if (index >= 0 && index < numLambdas)
    {
        val = lambdas[index].getLambda();
    }
    return val;
}

void Fleet::setLambdaSizeFreq(int index, int szfq)
{
    if (index >= 0 && index < numLambdas)
    {
        lambdas[index].setSizeFreq(szfq);
    }
}

int Fleet::getLambdaSizeFreq(int index)
{
    int val = 0;
    if (index >= 0 && index < numLambdas)
    {
        val = lambdas[index].getSizeFreq();
    }
    return val;
}
*/

void Fleet::appendLambda(QStringList values)
{
    int rows = lambdaModel->rowCount();
    lambdaModel->setRowCount(rows + 1);
    lambdaModel->setRowData(rows, values);
}

bool Fleet::getActive() const
{
    return active;
}

void Fleet::setActive(bool value)
{
    active = value;
}

