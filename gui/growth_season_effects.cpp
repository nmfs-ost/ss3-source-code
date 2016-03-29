#include "growth_season_effects.h"
#include "parametermodel.h"

GrowthSeasonalEffects::GrowthSeasonalEffects()
{
    effects = new tablemodel();
    effects->setRowCount(1);
    effHeader << "FWtLen1" << "FWtLen2" << "Mat1" << "Mat2" << "Fec1" << "Fec2";
    effHeader << "MWtLen1" << "MWtLen2" << "L1" << "K";
    effects->setHeader(effHeader);
    effects->setRowHeader(0, "");
    paramtable = new parametermodel();
    clear();
}

GrowthSeasonalEffects::GrowthSeasonalEffects (const GrowthSeasonalEffects &other)
{
    copy (other);
}

GrowthSeasonalEffects::~GrowthSeasonalEffects ()
{
    clear();
    delete effects;
    delete paramtable;
}

void GrowthSeasonalEffects::setEffects(QStringList qlst)
{
    effects->setRowData(0, qlst);
}

QStringList GrowthSeasonalEffects::getEffects() const
{
    return effects->getRowData(0);
}

float GrowthSeasonalEffects::getFemaleWtLen1() const
{
    return FemaleWtLen1;
}

void GrowthSeasonalEffects::setFemaleWtLen1(float value)
{
    FemaleWtLen1 = value;
}
float GrowthSeasonalEffects::getFemaleWtLen2() const
{
    return FemaleWtLen2;
}

void GrowthSeasonalEffects::setFemaleWtLen2(float value)
{
    FemaleWtLen2 = value;
}
float GrowthSeasonalEffects::getMaleWtLen1() const
{
    return MaleWtLen1;
}

void GrowthSeasonalEffects::setMaleWtLen1(float value)
{
    MaleWtLen1 = value;
}
float GrowthSeasonalEffects::getMaleWtLen2() const
{
    return MaleWtLen2;
}

void GrowthSeasonalEffects::setMaleWtLen2(float value)
{
    MaleWtLen2 = value;
}
float GrowthSeasonalEffects::getMat1() const
{
    return mat1;
}

void GrowthSeasonalEffects::setMat1(float value)
{
    mat1 = value;
}
float GrowthSeasonalEffects::getMat2() const
{
    return mat2;
}

void GrowthSeasonalEffects::setMat2(float value)
{
    mat2 = value;
}
float GrowthSeasonalEffects::getFec1() const
{
    return fec1;
}

void GrowthSeasonalEffects::setFec1(float value)
{
    fec1 = value;
}
float GrowthSeasonalEffects::getFec2() const
{
    return fec2;
}

void GrowthSeasonalEffects::setFec2(float value)
{
    fec2 = value;
}
float GrowthSeasonalEffects::getL1() const
{
    return l1;
}

void GrowthSeasonalEffects::setL1(float value)
{
    l1 = value;
}
float GrowthSeasonalEffects::getK() const
{
    return k;
}

void GrowthSeasonalEffects::setK(float value)
{
    k = value;
}
int GrowthSeasonalEffects::getNumParams() const
{
    return paramtable->rowCount();
}

void GrowthSeasonalEffects::setNumParams(int value)
{
    paramtable->setRowCount(value);
}

QStringList GrowthSeasonalEffects::getParameter(int index) const
{
    return paramtable->getRowData(index);
}

void GrowthSeasonalEffects::setParameter(int i, QString str)
{
    QStringList qlst(str.split(' ', QString::SkipEmptyParts));
    paramtable->setRowData(i, qlst);
}

void GrowthSeasonalEffects::setParameter(int i, QStringList datalist)
{
    paramtable->setRowData(i, datalist);
}

GrowthSeasonalEffects & GrowthSeasonalEffects::copy (const GrowthSeasonalEffects &other)
{
    QStringList values(other.getEffects());
    effects->setRowData(0, values);
    paramtable->setRowCount(other.getNumParams());
    for (int i = 0; i < paramtable->rowCount(); i++)
    {
        values = other.getParameter(i);
        paramtable->setRowData(i, values);
    }
    return *this;
}

GrowthSeasonalEffects & GrowthSeasonalEffects::operator = (const GrowthSeasonalEffects &other)
{
    return copy (other);
}

void GrowthSeasonalEffects::clear()
{
    QStringList qlst;
    qlst <<"0"<<"0"<<"0"<<"0"<<"0"<<"0"<<"0"<<"0"<<"0"<<"0";
    effects->setRowData(0, qlst);
    paramtable->setRowCount(0);
}








