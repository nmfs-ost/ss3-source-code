#ifndef OBSERVATION_H
#define OBSERVATION_H

#include <QList>
#include <QString>
#include <QWidget>

#include "tablemodel.h"

/**  This is a generalized holder of observational data. It includes vectors
 * for variable length data for both genders as well as sample sizes.
 * The data is indexed by year, season, and fleet.
  */

class ssObservation
{
public:
    ssObservation(int size = 0);
    ~ssObservation();

public slots:
    void fromText (QString line);
    QString toText ();

    /** the metadata */

    /** the female data vector */

    /** the male data vector */

    /** Convenience functions */

    void setNumBins(int bins, int numGenders);
    int getNumBins();
    void setNumObs(int obs);
    int getNumObs();

    void addObservation(QStringList txtlst);
    void setObservation(int index, QStringList txtlst);
    QStringList getObservation(int index);

    tablemodel * getObservations() {return observations;}

protected:
    int numBins;
    int numObs;

    tablemodel *observations;
    QStringList obsHeader;

};

class meanBwtObservation : public ssObservation
{
public:
    meanBwtObservation();

    void setDegFreedom(int deg) {numBins = deg;}
    int getDegFreedom() {return numBins;}
};

class lengthObservation : public ssObservation
{
public:
    lengthObservation();

};

class ageObservation : public ssObservation
{
public:
    ageObservation();

};

class saaObservation : public ssObservation
{
public:
    saaObservation();

    void setNumBins(int num, int numGenders);

};

class environmentalVars : public ssObservation
{
public:
    environmentalVars();

public slots:
    void setNumVars(int num) {numVars = num;}
    int getNumVars() {return numVars;}

private:
    int numVars;
};

class tagObservation : public ssObservation
{
public:
    tagObservation();

    void setNumTagGroups(int num) {setNumObs(num);}
    int getNumTagGroups() {return getNumObs();}

    void setLatency(int n_periods) {numPeriods = n_periods;}
    int getLatency () {return numPeriods;}

    void setMaxPeriods (int max) {maxPeriods = max;}
    int getMaxPeriods () {return maxPeriods;}

private:
    int numPeriods;
    int maxPeriods;

};

class recapObservation : public ssObservation
{
public:
    recapObservation();

    void setNumRecapEvnts(int num) {setNumObs(num);}
    int getNumRecapEvnts() {return getNumObs();}

};

class morphObservation : public ssObservation
{
public:
    morphObservation();

    void setNumMorphs(int num);
    int getNumMorphs ();
};

class generalObservation : public ssObservation
{
public:
    generalObservation();

};

class recruitDevs : public ssObservation
{
public:
    recruitDevs();

    void setNumRecruitDevs(int val) {observations->setRowCount(val);}
    int getNumRecruitDevs() {return observations->rowCount();}

    QStringList getRecruitDev (int index) {return getObservation(index);}
    void setRecruitDev (int index, QStringList data) {setObservation(index, data);}
};

#endif // OBSERVATION_H
