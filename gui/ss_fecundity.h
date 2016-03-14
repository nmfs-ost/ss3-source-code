#ifndef SS_FECUNDITY_H
#define SS_FECUNDITY_H

#include <QStringList>

#include "parametermodel.h"

class ss_fecundity
{
public:
    ss_fecundity();
    ~ss_fecundity();

    int getMethod() const;
    void setMethod(int value);

    void setHermParam (int index, QStringList data);
    QStringList getHermParam(int index) {return hermaphParams->getRowData(index);}
    tablemodel *getHermParams() {return hermaphParams;}

    void setFemaleParam (int index, QStringList data);
    QStringList getFemaleParam(int index) {return femaleParams->getRowData(index);}
    tablemodel *getFemaleParams() {return femaleParams;}

    int getHermIncludeMales() const;
    void setHermIncludeMales(int value);

    int getHermSeason() const;
    void setHermSeason(int value);

    bool getHermaphroditism() const;
    void setHermaphroditism(bool value);

private:
    int method;
    bool hermaphroditism;
    int hermSeason;
    int hermIncludeMales;

    QString pHeader;
    parametermodel *hermaphParams;
    QStringList fVHeader;
    parametermodel *femaleParams;
};

#endif // SS_FECUNDITY_H
