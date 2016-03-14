#ifndef GROWTH_PATTERN_H
#define GROWTH_PATTERN_H

#include "growth_morph.h"
#include "parametermodel.h"

class growthPattern
{
public:
    growthPattern();
    growthPattern(const growthPattern &rhs);
    ~growthPattern();

    int getNum_morphs() const;
    void setNum_morphs(int value);

    growth_morph * getMorph(int index) const;
    void setMorph(int index, growth_morph *&value);

    growthPattern &operator =(const growthPattern &rhs);

    void setNumNatMParams (int num) {natMParams->setRowCount(num);}
    int getNumNatMParams () {return natMParams->rowCount();}
    void addNatMParam (QStringList data) {setNatMParam(natMParams->rowCount(), data);}
    void setNatMParam (QStringList data) {setNatMParam(0, data);}
    void setNatMParam (int index, QStringList data);
    QStringList getNatMParam(int index) {return natMParams->getRowData(index);}
    tablemodel *getNatMParams() {return natMParams;}

    void setNumGrowthParams (int num) {growthParams->setRowCount(num);}
    int getNumGrowthParams () {return growthParams->rowCount();}
    void addGrowthParam (QStringList data) {setGrowthParam(growthParams->rowCount(), data);}
    void setGrowthParam (int index, QStringList data);
    QStringList getGrowthParam(int index) {return growthParams->getRowData(index);}
    tablemodel *getGrowthParams() {return growthParams;}

    void setNumCVParams (int num) {cvParams->setRowCount(num);}
    int getNumCVParams () {return cvParams->rowCount();}
    void addCVParam (QStringList data) {setCVParam(cvParams->rowCount(), data);}
    void setCVParam (int index, QStringList data);
    QStringList getCVParam(int index) {return cvParams->getRowData(index);}
    tablemodel *getCVParams() {return cvParams;}

    void setNumDevParams (int num) {devParams->setRowCount(num);}
    int getNumDevParams () {return devParams->rowCount();}
    void addDevParam (QStringList data) {setDevParam(devParams->rowCount(), data);}
    void setDevParam (int index, QStringList data);
    QStringList getDevParam(int index) {return devParams->getRowData(index);}
    tablemodel *getDevParams() {return devParams;}

private:

    int num_morphs;
    QList<growth_morph *> morphs;

    void clear();
    growthPattern& copy (const growthPattern &rhs);

    parametermodel *natMParams;
    parametermodel *growthParams;
    parametermodel *cvParams;

    parametermodel *devParams;

};

#endif // GROWTH_PATTERN_H
