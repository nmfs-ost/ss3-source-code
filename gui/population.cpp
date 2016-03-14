#include "population.h"

population::population(QWidget *parent) :
    QObject(parent)
{
    QStringList header;
    pop_growth = new ss_growth();
    pop_fecundity = new ss_fecundity();
    pop_recruitment = new spawn_recruit();
    pop_mortality = new ss_mortality();
    pop_movement = new ss_movement();
    meanBwtModel = new tablemodel(this);
    meanBwtModel->setColumnCount(20);
    header << "Year" << "Seas" << "Type" << "Part" << "Value" << "CV";
    meanBwtModel->setHeader(header);
    seasparamtable = new parametermodel(this);
    header.clear();
    header << "st_age" << "st_age bias" << "max_age bias" << "bias coeff" << "st_age sd" << "max_age sd" << "sd coeff";
    seasparamtable->setColumnCount(7);
    seasparamtable->setHeader(header);
    reset();
}

population::~population()
{
    delete meanBwtModel;
    delete pop_growth;
    delete pop_fecundity;
    delete pop_recruitment;
    delete pop_mortality;
    delete pop_movement;
}

void population::reset()
{
    set_frac_female(0.5);
    M()->setMethod(1);

    i_gender = 1;
    i_mean_bwt_deg_freedom = 1;
    i_mean_bwt_count = 1;

    meanBwtModel->setRowCount(0);

    femwtlen1 = 0.0;
    femwtlen2 = 0.0;
    mat1 = 0.0;
    mat2 = 0.0;
    fec1 = 0.0;
    fec2 = 0.0;

    malewtlen1 = 0.0;
    malewtlen2 = 0.0;
    L1 = 0.0;
    K = 0.0;
    setNumSeasParams();
}

void population::setStartYear(int yr)
{
    iStartYear = yr;
    M()->setStartYear(yr);
}

void population::setTotalYears(int yrs)
{
    iNumYears = yrs;
    M()->setNumYears(yrs);
}

void population::setNumAges(int ages)
{
    iNumAges = ages;
    Grow()->setNumAges(ages);
}

float population::get_frac_female() const
{
    return f_frac_female;
}

void population::set_frac_female(float value)
{
    f_frac_female = value;
}
int population::getK() const
{
    return K;
}

void population::setK(int value)
{
    K = value;
}

int population::getL1() const
{
    return L1;
}

void population::setL1(int value)
{
    L1 = value;
}

int population::getMalewtlen2() const
{
    return malewtlen2;
}

void population::setMalewtlen2(int value)
{
    malewtlen2 = value;
}

int population::getMalewtlen1() const
{
    return malewtlen1;
}

void population::setMalewtlen1(int value)
{
    malewtlen1 = value;
}

int population::getFec2() const
{
    return fec2;
}

void population::setFec2(int value)
{
    fec2 = value;
}

int population::getFec1() const
{
    return fec1;
}

void population::setFec1(int value)
{
    fec1 = value;
}

int population::getMat2() const
{
    return mat2;
}

void population::setMat2(int value)
{
    mat2 = value;
}

int population::getMat1() const
{
    return mat1;
}

void population::setMat1(int value)
{
    mat1 = value;
}

int population::getFemwtlen2() const
{
    return femwtlen2;
}

void population::setFemwtlen2(int value)
{
    femwtlen2 = value;
}

int population::getFemwtlen1() const
{
    return femwtlen1;
}

void population::setFemwtlen1(int value)
{
    femwtlen1 = value;
}

void population::setNumSeasParams()
{
    int num = femwtlen1 + femwtlen2;
    num += mat1 + mat2;
    num += fec1 + fec2;
    num += malewtlen1 + malewtlen2;
    num += L1 + K;
    seasparamtable->setRowCount(num);
}

void population::setSeasParam(int index, QStringList data)
{
    if (index >= seasparamtable->rowCount())
        seasparamtable->setRowCount(index + 1);
    seasparamtable->setRowData(index, data);
}

QStringList population::getSeasParam(int index)
{
    return seasparamtable->getRowData(index);
}

void population::readSeasonalEffects(ss_file *input)
{
    femwtlen1 = input->next_value().toFloat();
    femwtlen2 = input->next_value().toFloat();
    mat1 = input->next_value().toFloat();
    mat2 = input->next_value().toFloat();
    fec1 = input->next_value().toFloat();
    fec2 = input->next_value().toFloat();
    malewtlen1 = input->next_value().toFloat();
    malewtlen2 = input->next_value().toFloat();
    L1 = input->next_value().toFloat();
    K = input->next_value().toFloat();
}

QString population::writeSeasonalEffects()
{
    QString line("");
    line.append(QString ("%1 %2 %3 %4 %5 %6 ").arg(
                    QString::number(femwtlen1),
                    QString::number(femwtlen2),
                    QString::number(mat1),
                    QString::number(mat2),
                    QString::number(fec1),
                    QString::number(fec2)));
    line.append(QString ("%1 %2 %3 %4").arg(
                    QString::number(malewtlen1),
                    QString::number(malewtlen2),
                    QString::number(L1),
                    QString::number(K)));
    return line;
}
